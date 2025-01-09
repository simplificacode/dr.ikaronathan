from itertools import chain
from types import NotImplementedType
from typing import Any
from typing_extensions import Self

from sympy.polys.matrices.sdm import SDM

class DDM(list):
    fmt = ...
    def __init__(self, rowslist, shape, domain) -> None: ...
    def getitem(self, i, j): ...
    def setitem(self, i, j, value) -> None: ...
    def extract_slice(self, slice1, slice2) -> DDM: ...
    def extract(self, rows, cols) -> DDM: ...
    def to_list(self) -> list[Any]: ...
    def to_list_flat(self) -> list[Any]: ...
    def flatiter(self) -> chain[Any]: ...
    def flat(self) -> list[Any]: ...
    def to_dok(self) -> dict[tuple[int, int], Any]: ...
    def to_ddm(self) -> Self: ...
    def to_sdm(self) -> SDM: ...
    def convert_to(self, K) -> DDM: ...
    def __str__(self) -> str: ...
    def __repr__(self) -> str: ...
    def __eq__(self, other) -> bool: ...
    def __ne__(self, other) -> bool: ...
    @classmethod
    def zeros(cls, shape, domain) -> DDM: ...
    @classmethod
    def ones(cls, shape, domain) -> DDM: ...
    @classmethod
    def eye(cls, size, domain) -> DDM: ...
    def copy(self) -> DDM: ...
    def transpose(self) -> DDM: ...
    def __add__(a, b) -> NotImplementedType | DDM: ...
    def __sub__(a, b) -> NotImplementedType | DDM: ...
    def __neg__(a) -> DDM: ...
    def __mul__(a, b) -> DDM | NotImplementedType: ...
    def __rmul__(a, b) -> DDM | NotImplementedType: ...
    def __matmul__(a, b) -> DDM | NotImplementedType: ...
    def add(a, b) -> DDM: ...
    def sub(a, b) -> DDM: ...
    def neg(a) -> DDM: ...
    def mul(a, b) -> DDM: ...
    def rmul(a, b) -> DDM: ...
    def matmul(a, b) -> DDM: ...
    def mul_elementwise(a, b) -> DDM: ...
    def hstack(A, *B) -> DDM: ...
    def vstack(A, *B) -> DDM: ...
    def applyfunc(self, func, domain) -> DDM: ...
    def scc(a) -> list[Any]: ...
    def rref(a) -> tuple[DDM, list[Any]]: ...
    def nullspace(a) -> tuple[DDM, list[Any]]: ...
    def particular(a) -> DDM: ...
    def det(a): ...
    def inv(a) -> DDM: ...
    def lu(a) -> tuple[DDM, DDM, list[Any]]: ...
    def lu_solve(a, b) -> DDM: ...
    def charpoly(a) -> list[Any]: ...
    def is_zero_matrix(self) -> bool: ...
    def is_upper(self) -> bool: ...
    def is_lower(self) -> bool: ...
    def lll(A, delta=...): ...
    def lll_transform(A, delta=...) -> tuple[Any, Any | None]: ...
