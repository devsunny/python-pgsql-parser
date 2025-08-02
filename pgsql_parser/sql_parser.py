from typing import List
from .sql_lexer import Token, TokenType, VOID_TOKEN


class Statement:
    __slots__ = ("tokens", "ast")

    def __init__(self, tokens):
        self.tokens = tokens
        self.ast = []

    def get_statement_ast(self):
        return self.ast

    def __repr__(self):
        return (
            f"Token({self.token_type.name}, '{self.value}', pos={self.start_position})"
        )


class AdvancedSQLParser:
    def __init__(self, stmt_tokens: List[Token]):
        self.tokens = stmt_tokens
        self.num_of_tokens = len(stmt_tokens)
        self.current_pos = 0
        self.statement = Statement(stmt_tokens)
        self._parse()

    def _look_ahead(self, num: int = 1):
        pos = self.current_pos + num
        if pos < self.num_of_tokens:
            return self.tokens[pos]
        return VOID_TOKEN

    def _consume(self, num: int = 1):
        buf = []
        for x in range(num):
            if self.current_pos < self.num_of_tokens:
                buf.append(self.tokens[self.current_pos])
                self.current_pos += 1
            else:
                break
        return buf

    def _consume_one(self):
        if self.current_pos < self.num_of_tokens:
            tok = self.tokens[self.current_pos]
            self.current_pos += 1
            return tok
        return VOID_TOKEN

    def _look_back(self, num: int = 1):
        pos = self.current_pos - num
        if pos > -1:
            return self.tokens[pos]
        return VOID_TOKEN

    def _read_enclosure(self):
        stack = 0
        tok_buf = []
        while self.current_pos < self.num_of_tokens:
            current_token = self.tokens[self.current_pos]
            if current_token.token_type == TokenType.OPEN_PAREN:
                stack = stack + 1
                tok_buf.append(self._consume_one())
            elif current_token.token_type == TokenType.CLOSE_PAREN:
                stack = stack - 1
                tok_buf.append(self._consume_one())
                if stack == 0:
                    break
            else:
                tok_buf.append(self._consume_one())

        return tok_buf

    def _parse(self):
        while self.current_pos < self.num_of_tokens:
            current_token = self.tokens[self.current_pos]
            if current_token.token_type == TokenType.OPEN_PAREN:
                toks = self._read_enclosure()
                if (
                    len(toks) > 2
                    and toks[1].token_type == TokenType.KEYWORD
                    and toks[1].value.upper() == "SELECT"
                ):
                    _parser = AdvancedSQLParser(toks[1:-1])
                    substmt = _parser.statement
                    self.statement.ast.append(toks[0])
                    self.statement.ast.append(substmt)
                    self.statement.ast.append(toks[-1])
                else:
                    self.statement.ast.extend(toks)
            else:
                self.statement.ast.append(self._consume_one())
