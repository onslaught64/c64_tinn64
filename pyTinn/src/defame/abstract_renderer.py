from abc import ABC, abstractmethod
from typing import IO


class AbstractRenderer(ABC):
    @abstractmethod
    def render_labels(self, file_handle: IO):
        pass

    @abstractmethod
    def render(self, file_handle: IO):
        pass
