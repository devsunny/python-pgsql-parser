# PostgreSQL SQL Parser

[![Python Version](https://img.shields.io/badge/python-3.7%2B-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PyPI Version](https://img.shields.io/pypi/v/python-pgsql-parser.svg)](https://pypi.org/project/python-pgsql-parser/)

A high-performance PostgreSQL SQL parser for extracting comprehensive database schema metadata from DDL scripts.

## Features

- **Complete SQL Parsing**: Tokenizes and parses PostgreSQL DDL statements
- **Schema Metadata Extraction**:
  - Database, schema, and table names
  - Table types (regular, temporary, view, materialized view)
  - Column definitions with data types, lengths, precision, and constraints
  - Primary keys, foreign keys, indexes, and constraints
- **Advanced SQL Support**:
  - Quoted identifiers
  - ANSI SQL and PostgreSQL-specific syntax
  - CREATE/ALTER TABLE statements
  - View and materialized view definitions
- **Powerful API**:
  - Parse entire scripts or individual statements
  - Retrieve tables by qualified name
  - Iterate through parsed statements
- **Well-Tested**: Comprehensive test suite with 95%+ coverage

## Installation

```bash
pip install python-pgsql-parser
```

## Quick Start

```python
from pgsql_parser import SQLParser

# Parse SQL script
sql_script = """
CREATE TABLE public.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE
);

CREATE VIEW user_emails AS
SELECT id, email FROM public.users;
"""

parser = SQLParser(sql_script)


# Get all tables
tables = parser.get_tables()
for table in tables:
    print(f"Table: {table.schema}.{table.name} ({table.table_type})")

# Get specific table
users_table = parser.get_table("users", schema="public")
if users_table:
    print(f"\nColumns in users table:")
    for col_name, column in users_table.columns.items():
        print(f"- {col_name}: {column.data_type}")
```

## Documentation

### Core Classes

- `SQLParser`: Main parser class
- `Table`: Represents a table/view definition
- `Column`: Contains column metadata
- `PrimaryKey`, `ForeignKey`, `Constraint`: Schema constraint objects

### Key Methods

- `parse_script(sql_script)`: Parse entire SQL script
- `parse_statement(sql)`: Parse single SQL statement
- `get_tables()`: Get all parsed tables/views
- `get_table(name, schema, database)`: Get specific table by qualified name
- `statement_generator(sql_script)`: Iterate through SQL statements

## Usage Examples
 - Please see Unit Test examples

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and feature requests, please [open an issue](https://github.com/yourusername/python-pgsql-parser/issues).