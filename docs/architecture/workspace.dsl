// Structurizr DSL - C4 model for {{PROJECT_NAME}}
// Render: https://structurizr.com/dsl or `docker run -p 8080:8080 structurizr/lite`
// Reference: https://c4model.com

workspace "{{PROJECT_NAME}}" "{{ONE_LINER}}" {

    model {
        user = person "User" "End user of the system"

        system = softwareSystem "{{PROJECT_NAME}}" "{{ONE_LINER}}" {
            web = container "Web Frontend" "User interface" "Vite + React + TypeScript" "Frontend"
            api = container "API" "REST API service" "Node.js / Python" "API"
            worker = container "Worker" "Async job processor" "BullMQ / Celery" "Worker"
            db = container "Database" "Transactional store" "Postgres 16" "Database" {
                tags "Database"
            }
            cache = container "Cache + Queue" "Cache + job queue" "Redis 7" "Cache" {
                tags "Database"
            }
            blob = container "Object Store" "Binary blob storage" "S3-compatible" "Storage" {
                tags "Database"
            }
        }

        external = softwareSystem "External Services" "Third-party providers (Sentry, OTel collector, LLM providers)" "External"

        // Relationships
        user -> web "Uses" "HTTPS"
        web -> api "Calls" "HTTPS /api/v1"
        api -> db "Reads/writes" "SQL"
        api -> cache "Reads/writes" "Redis protocol"
        api -> blob "Stores blobs" "HTTPS"
        api -> cache "Enqueues jobs" "Redis"
        cache -> worker "Delivers jobs" "Redis"
        worker -> db "Reads/writes" "SQL"
        worker -> blob "Reads/writes" "HTTPS"
        api -> external "Telemetry + LLM calls" "HTTPS"
        worker -> external "Telemetry + LLM calls" "HTTPS"
    }

    views {
        systemContext system "SystemContext" {
            include *
            autolayout lr
            description "System context for {{PROJECT_NAME}}"
        }

        container system "Container" {
            include *
            autolayout lr
            description "Container view"
        }

        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Database" {
                shape Cylinder
            }
            element "Frontend" { background #438dd5; color #ffffff }
            element "API"      { background #2e7d32; color #ffffff }
            element "Worker"   { background #f57c00; color #ffffff }
            element "Cache"    { background #c62828; color #ffffff }
            element "Storage"  { background #6a1b9a; color #ffffff }
        }

        theme default
    }
}
