```markdown
# PostgreSQL SQL Parser Documentation

## Overview
A Python library for parsing PostgreSQL DDL scripts to extract comprehensive database schema metadata. Features include:
- Complete SQL parsing with PostgreSQL-specific syntax support
- Schema metadata extraction (tables, columns, constraints, relationships)
- Support for quoted identifiers and complex DDL statements
- Large script processing with statement-by-statement parsing
- Intuitive API for accessing parsed schema information

## Installation
```bash
pip install python-pgsql-parser
```

## Quick Start
```python
from pgsql_parser import SQLParser

parser = SQLParser()
sql = """
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE
);
"""

parser.parse_script(sql)
table = parser.get_table("users")
print(f"Table: {table.name}")
for col_name, column in table.columns.items():
    print(f"  {col_name}: {column.data_type}")
```

## Core Concepts

### Tokenization
The lexer converts SQL input into tokens (keywords, identifiers, literals, etc.)

### Parsing
Processes tokens to identify database objects and their properties

### Schema Objects
- **Table**: Database table with columns and constraints
- **Column**: Table column metadata
- **PrimaryKey**: Primary key constraint
- **ForeignKey**: Foreign key relationship
- **Constraint**: Table constraints (CHECK, UNIQUE, etc.)

## API Reference

### SQLParser Class
| Method | Description |
|--------|-------------|
| `parse_script(sql_script: str)` | Parse entire SQL script |
| `parse_statement(sql: str) -> Optional[Table]` | Parse single SQL statement |
| `get_tables() -> List[Table]` | Get all parsed tables/views |
| `get_table(name: str, schema: str, database: str) -> Optional[Table]` | Get table by qualified name |
| `statement_generator(sql_script: str) -> Generator[str, None, None]` | Iterate through SQL statements |

### Table Class
| Property | Description |
|----------|-------------|
| `name` | Table name |
| `schema` | Schema name |
| `database` | Database name |
| `table_type` | Type ('TABLE', 'VIEW', etc.) |
| `columns` | Dictionary of Column objects |
| `primary_key` | PrimaryKey object |
| `foreign_keys` | List of ForeignKey objects |
| `constraints` | List of Constraint objects |
| `is_view` | True if view |
| `view_definition` | View SQL definition |

### Column Class
| Property | Description |
|----------|-------------|
| `name` | Column name |
| `data_type` | Data type (e.g., 'varchar') |
| `char_length` | Character length for strings |
| `numeric_precision` | Precision for numeric types |
| `numeric_scale` | Scale for numeric types |
| `nullable` | True if allows NULL |
| `default` | Default value expression |
| `is_primary` | True if part of primary key |
| `primary_key_position` | Position in primary key |
| `foreign_key_ref` | Foreign key reference |

## Examples

### Basic Table Parsing
```python
sql = """
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    category_id INT REFERENCES categories(id)
);
"""

parser.parse_script(sql)
table = parser.get_table("products")
print(f"Primary Key: {table.primary_key.columns}")
```

### Handling ALTER TABLE
```python
sql = """
ALTER TABLE products
ADD COLUMN description TEXT,
ADD CONSTRAINT unique_name UNIQUE (name);
"""

parser.parse_statement(sql)
table = parser.get_table("products")
print("New column:", "description" in table.columns)
```

### Processing Views
```python
sql = """
CREATE VIEW expensive_products AS
SELECT * FROM products WHERE price > 100;
"""

parser.parse_script(sql)
view = parser.get_table("expensive_products")
print(f"View definition: {view.view_definition[:50]}...")
```

## Advanced Usage

### Processing Large Scripts
```python
with open("large_schema.sql") as f:
    sql_script = f.read()

parser = SQLParser()
for stmt in parser.statement_generator(sql_script):
    parser.parse_statement(stmt)
    for table in parser.get_tables():
        save_to_database(table)
```

### Schema Report Generation
```python
def print_schema(parser):
    for table in parser.get_tables():
        print(f"\nTable: {table.name} ({table.table_type})")
        print("Columns:")
        for col in table.columns.values():
            details = [
                f"Type: {col.data_type}",
                f"Nullable: {col.nullable}",
                f"Primary: {col.is_primary}"
            ]
            print(f"- {col.name}: {', '.join(details)}")
```

## Contributing
1. Fork the repository
2. Create feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -am 'Add feature'`)
4. Push to branch (`git push origin feature/your-feature`)
5. Open pull request

**Guidelines:**
- Write clear commit messages
- Include tests for new features
- Update documentation
- Follow PEP 8 style

## License
MIT License - See [LICENSE](https://opensource.org/licenses/MIT) for details
```