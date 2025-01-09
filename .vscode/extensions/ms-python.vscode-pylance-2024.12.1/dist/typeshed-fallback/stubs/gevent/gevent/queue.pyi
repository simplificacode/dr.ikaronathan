import sys
from collections import deque
from collections.abc import Iterable

# technically it is using _PySimpleQueue, which has the same interface as SimpleQueue
from queue import Empty as Empty, Full as Full, SimpleQueue as SimpleQueue
from typing import Any, Generic, Literal, TypeVar, final, overload
from typing_extensions import Self

from gevent._waiter import Waiter
from gevent.hub import Hub

__all__ = ["Queue", "PriorityQueue", "LifoQueue", "SimpleQueue", "JoinableQueue", "Channel", "Empty", "Full", "ShutDown"]

if sys.version_info >= (3, 13):
    from queue import ShutDown as ShutDown
else:
    class ShutDown(Exception): ...

_T = TypeVar("_T")

class Queue(Generic[_T]):
    @property
    def hub(self) -> Hub: ...  # readonly in Cython
    @property
    def queue(self) -> deque[_T]: ...  # readonly in Cython
    maxsize: int | None
    is_shutdown: bool
    @overload
    def __init__(self, maxsize: int | None = None) -> None: ...
    @overload
    def __init__(self, maxsize: int | None, items: Iterable[_T]) -> None: ...
    @overload
    def __init__(self, maxsize: int | None = None, *, items: Iterable[_T]) -> None: ...
    def copy(self) -> Self: ...
    def empty(self) -> bool: ...
    def full(self) -> bool: ...
    def get(self, block: bool = True, timeout: float | None = None) -> _T: ...
    def get_nowait(self) -> _T: ...
    def peek(self, block: bool = True, timeout: float | None = None) -> _T: ...
    def peek_nowait(self) -> _T: ...
    def put(self, item: _T, block: bool = True, timeout: float | None = None) -> None: ...
    def put_nowait(self, item: _T) -> None: ...
    def qsize(self) -> int: ...
    def shutdown(self, immediate: bool = False) -> None: ...
    def __bool__(self) -> bool: ...
    def __iter__(self) -> Self: ...
    def __len__(self) -> int: ...
    def __next__(self) -> _T: ...
    next = __next__

@final
class UnboundQueue(Queue[_T]):
    @overload
    def __init__(self, maxsize: None = None) -> None: ...
    @overload
    def __init__(self, maxsize: None, items: Iterable[_T]) -> None: ...
    @overload
    def __init__(self, maxsize: None = None, *, items: Iterable[_T]) -> None: ...

class PriorityQueue(Queue[_T]): ...
class LifoQueue(Queue[_T]): ...

class JoinableQueue(Queue[_T]):
    @property
    def unfinished_tasks(self) -> int: ...  # readonly in Cython
    @overload
    def __init__(self, maxsize: int | None = None, *, unfinished_tasks: int | None = None) -> None: ...
    @overload
    def __init__(self, maxsize: int | None, items: Iterable[_T], unfinished_tasks: int | None = None) -> None: ...
    @overload
    def __init__(self, maxsize: int | None = None, *, items: Iterable[_T], unfinished_tasks: int | None = None) -> None: ...
    def join(self, timeout: float | None = None) -> bool: ...
    def task_done(self) -> None: ...

class Channel(Generic[_T]):
    @property
    def getters(self) -> deque[Waiter[Any]]: ...  # readonly in Cython
    @property
    def putters(self) -> deque[tuple[_T, Waiter[Any]]]: ...  # readonly in Cython
    @property
    def hub(self) -> Hub: ...  # readonly in Cython
    def __init__(self, maxsize: Literal[1] = 1) -> None: ...
    @property
    def balance(self) -> int: ...
    def qsize(self) -> Literal[0]: ...
    def empty(self) -> Literal[True]: ...
    def full(self) -> Literal[True]: ...
    def put(self, item: _T, block: bool = True, timeout: float | None = None) -> None: ...
    def put_nowait(self, item: _T) -> None: ...
    def get(self, block: bool = True, timeout: float | None = None) -> _T: ...
    def get_nowait(self) -> _T: ...
    def __iter__(self) -> Self: ...
    def __next__(self) -> _T: ...
    next = __next__
