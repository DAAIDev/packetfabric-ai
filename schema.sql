CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'user' CHECK (role IN ('admin', 'user', 'readonly')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE TABLE access_control (
    acl_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    resource_type VARCHAR(50) NOT NULL,
    resource_id VARCHAR(255),
    permission VARCHAR(50) NOT NULL CHECK (permission IN ('read', 'write', 'delete', 'admin')),
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID REFERENCES users(user_id),
    UNIQUE(user_id, resource_type, resource_id, permission)
);

CREATE TABLE documents (
    document_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_url TEXT,
    title VARCHAR(500) NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    category VARCHAR(100),
    version VARCHAR(50) DEFAULT '1.0',
    content_hash VARCHAR(64) NOT NULL,
    raw_content TEXT,
    normalized_content TEXT,
    metadata JSONB,
    storage_path TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    indexed_at TIMESTAMP
);

CREATE TABLE chunks (
    chunk_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(document_id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    chunk_text TEXT NOT NULL,
    token_count INTEGER,
    embedding_id VARCHAR(255),
    embedding_model VARCHAR(100),
    chunk_metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_id, chunk_index)
);

CREATE TABLE query_logs (
    query_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    session_id UUID,
    query_text TEXT NOT NULL,
    query_embedding_id VARCHAR(255),
    retrieved_chunk_ids UUID[],
    retrieval_scores FLOAT[],
    claude_prompt TEXT,
    claude_response TEXT,
    response_metadata JSONB,
    response_time_ms INTEGER,
    feedback_score INTEGER CHECK (feedback_score BETWEEN 1 AND 5),
    feedback_text TEXT,
    has_hallucination BOOLEAN,
    braintrust_log_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE provisioning_orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    query_id UUID REFERENCES query_logs(query_id) ON DELETE SET NULL,
    service_type VARCHAR(100) NOT NULL,
    configuration JSONB NOT NULL,
    estimated_price DECIMAL(10, 2),
    quote_id VARCHAR(255),
    pf_service_id VARCHAR(255),
    pf_order_id VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN (
        'pending', 'validating', 'quoted', 'provisioning', 
        'active', 'failed', 'cancelled', 'decommissioned'
    )),
    status_message TEXT,
    error_details JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    provisioned_at TIMESTAMP,
    decommissioned_at TIMESTAMP
);

CREATE TABLE provisioning_status_history (
    history_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES provisioning_orders(order_id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL,
    status_message TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);

CREATE TABLE api_usage_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    order_id UUID REFERENCES provisioning_orders(order_id) ON DELETE SET NULL,
    endpoint VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    request_payload JSONB,
    response_status INTEGER,
    response_payload JSONB,
    response_time_ms INTEGER,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ingestion_jobs (
    job_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_type VARCHAR(50) NOT NULL,
    source_url TEXT,
    status VARCHAR(50) DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed', 'cancelled')),
    documents_processed INTEGER DEFAULT 0,
    documents_failed INTEGER DEFAULT 0,
    error_log JSONB,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE system_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(user_id)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_acl_user_id ON access_control(user_id);
CREATE INDEX idx_documents_type ON documents(document_type);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_chunks_document_id ON chunks(document_id);
CREATE INDEX idx_query_logs_user_id ON query_logs(user_id);
CREATE INDEX idx_query_logs_created ON query_logs(created_at DESC);
CREATE INDEX idx_orders_user_id ON provisioning_orders(user_id);
CREATE INDEX idx_orders_status ON provisioning_orders(status);
CREATE INDEX idx_orders_created ON provisioning_orders(created_at DESC);
CREATE INDEX idx_status_history_order_id ON provisioning_status_history(order_id);
CREATE INDEX idx_api_logs_user_id ON api_usage_logs(user_id);
CREATE INDEX idx_api_logs_created ON api_usage_logs(created_at DESC);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON provisioning_orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

INSERT INTO users (email, username, full_name, role) VALUES
('admin@packetfabric.ai', 'admin', 'System Admin', 'admin'),
('test@packetfabric.ai', 'testuser', 'Test User', 'user');

INSERT INTO system_config (config_key, config_value, description) VALUES
('embedding_model', '"claude-3-sonnet"', 'Current embedding model in use'),
('chunk_size', '500', 'Token count per chunk'),
('chunk_overlap', '50', 'Token overlap between chunks'),
('max_retrieval_chunks', '5', 'Maximum chunks to retrieve per query'),
('claude_model', '"claude-3-5-sonnet-20241022"', 'Claude model for responses');
