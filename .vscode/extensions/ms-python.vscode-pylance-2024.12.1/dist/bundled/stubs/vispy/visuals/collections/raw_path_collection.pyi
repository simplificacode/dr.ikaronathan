# -*- coding: utf-8 -*-
# -----------------------------------------------------------------------------
# Copyright (c) 2014, Nicolas P. Rougier
# Distributed under the (new) BSD License. See LICENSE.txt for more info.
# -----------------------------------------------------------------------------
import numpy as np
from numpy.typing import ArrayLike, NDArray

from ... import glsl
from ...util.svg.transform import Transform
from ..transforms import NullTransform
from .collection import Collection

class RawPathCollection(Collection):
    def __init__(
        self,
        user_dtype: ArrayLike | None = None,
        transform: Transform | None = None,
        vertex: str | None = None,
        fragment: str | None = None,
        **kwargs,
    ): ...
    def append(self, P: NDArray, closed: bool = False, itemsize: int | None = None, **kwargs): ...
