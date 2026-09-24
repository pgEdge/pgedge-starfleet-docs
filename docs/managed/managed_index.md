# pgEdge Starfleet - Enterprise-Grade AI-First PostgreSQL

pgEdge Starfleet is a Postgres cloud platform that combines a smooth
developer experience and AI native tooling with the deployment flexibility,
security, and reliability the enterprise demands.

## What Makes pgEdge Starfleet Different?

pgEdge Starfleet stands apart from other Postgres cloud services with:

- comprehensive agentic AI tooling, provided by the pgEdge AI Toolkit:

    - The MCP Server supports both development and production use, and
      connects directly to Claude Code, Claude Cowork, Cursor, Replit,
      and other agentic tooling.

    - The RAG Server builds retrieval-augmented generation and chatbot
      applications entirely from data in Postgres.

- true copy-on-write
  [database branching](using_database/managed_branches.md) for parallel
  agentic experiments and for separate development, testing, and staging
  databases, without replacing the Postgres storage layer with a
  proprietary alternative.

- a smooth developer experience, with a free trial requiring no credit
  card, a database that deploys and connects in under two minutes, and
  MCP and RAG Servers and PostgREST access added as needed, at flat,
  predictable pricing.

- control, monitoring, and management from a web console, an API, or the
  command line, with regular backups and continuous monitoring included.

- flexible deployment options, starting on pgEdge-hosted infrastructure,
  then moving to the pgEdge cloud, your own cloud, or on-premises
  infrastructure, including air-gapped environments, using curated,
  validated platform binaries for pgEdge Enterprise Postgres.

- security by default, with database infrastructure closed to the
  internet, IP allowlisting restricting access, and the integrated MCP
  Server enforcing security and governance guardrails, including truly
  read-only connections.

- global scalability, starting with a single Postgres instance, scaling
  through progressively larger compute sizes, and growing to a
  multi-region cluster for high availability and zero downtime.

- 100 percent open-source Postgres, built on pgEdge Enterprise Postgres,
  itself 100 percent standard community Postgres, with all pgEdge and
  third-party extensions open source under the PostgreSQL license or an
  OSI-approved equivalent.

- compatibility with the PostgreSQL ecosystem, tools, and extensions,
  such as PostGIS, pgvector, pgCat, and pgBackRest.

- edge platform integration, well suited for use with edge development
  platforms and software such as Cloudflare Workers, Terraform, Vercel,
  and Fastly.

- support from Postgres community contributors, including a Postgres
  core team member, significant contributors, authors of popular
  Postgres books, and members of regional Postgres community boards in
  North America and Europe.
