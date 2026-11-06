#!/usr/bin/env python3
"""Calculate a capacity-only embedded-memory lower bound."""
import argparse
import math

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("--depth", type=int, required=True)
p.add_argument("--width", type=int, required=True)
p.add_argument("--block-kbits", type=int, default=18, help="Nominal block capacity in Kibit; default 18")
a = p.parse_args()
if min(a.depth, a.width, a.block_kbits) <= 0:
    p.error("depth, width and block-kbits must be positive")
bits = a.depth * a.width
block_bits = a.block_kbits * 1024
print(f"Logical storage: {a.depth} x {a.width} = {bits:,} bits")
print(f"Nominal block capacity: {block_bits:,} bits")
print(f"Capacity-only lower bound: {math.ceil(bits / block_bits)} block(s)")
print("Caution: width/depth modes, ports, parity, collision behavior and tool inference may increase usage or prevent mapping.")
