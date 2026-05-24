class LatencyCompensator:
    def __init__(self, network_delay_ms=30, processing_delay_ms=50):
        self.network_delay = network_delay_ms / 1000.0
        self.processing_delay = processing_delay_ms / 1000.0

    def correct(self, server_receive_time, client_capture_time):
        raw = server_receive_time - client_capture_time
        return max(0.0, raw - self.network_delay - self.processing_delay)