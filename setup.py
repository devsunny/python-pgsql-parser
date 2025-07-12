from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="python-pgsql-parser",
    version="0.1.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="PostgreSQL SQL parser for extracting table definitions and metadata",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/python-pgsql-parser",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Operating System :: OS Independent",
        "Topic :: Database",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
    python_requires=">=3.7",
    keywords="sql parser postgresql ddl metadata",
    install_requires=[],
    extras_require={
        "dev": ["pytest>=7.0", "twine>=4.0"],
    },
)