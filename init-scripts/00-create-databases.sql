-- Create databases for each project
-- This script runs automatically when PostgreSQL container starts for the first time

-- Create sporthorizon database
CREATE DATABASE sporthorizon;

-- Create vaitask database
CREATE DATABASE vaitask;

-- Connect to sporthorizon and enable extensions
\c sporthorizon
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- Create schemas for sporthorizon
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS providers;
CREATE SCHEMA IF NOT EXISTS timeseries;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS powerbi;

-- Connect to vaitask and enable extensions
\c vaitask
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
