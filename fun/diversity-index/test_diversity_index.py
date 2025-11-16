import math
from diversity_index import shannon_index, simpson_index, pielou_evenness, compute_metrics

sample_counts = {
    "east_asian": 8,
    "latinx": 7,
    "mediterranean": 5,
    "south_asian": 5,
    "african": 4,
    "middle_eastern": 4,
    "european": 3,
    "general": 3,
    "uncategorized": 3,
}

def test_metrics_basic():
    metrics = compute_metrics(sample_counts)
    assert metrics["total"] == sum(sample_counts.values())
    assert metrics["richness"] == len(sample_counts)
    # Shannon should be > 0
    assert metrics["shannon"] > 0
    # Simpson in (0,1)
    assert 0 < metrics["simpson"] < 1
    # Evenness <= 1
    assert 0 <= metrics["pielou_evenness"] <= 1

def test_shannon_manual():
    # Two equally frequent categories
    counts = {"a": 10, "b": 10}
    h = shannon_index(counts)
    expected = -2 * (0.5 * math.log(0.5))
    assert abs(h - expected) < 1e-9

def test_simpson_manual():
    counts = {"a": 10, "b": 10}
    s = simpson_index(counts)
    # Simpson diversity = 1 - sum(p_i^2) = 1 - (0.25 + 0.25) = 0.5
    assert abs(s - 0.5) < 1e-9

def test_pielou_evenness():
    counts = {"a": 10, "b": 10}
    e = pielou_evenness(counts)
    # Evenness should be 1 when perfectly even
    assert abs(e - 1.0) < 1e-9
