#!/bin/bash
# DishesRoter=(Purity John Boni)
DishesRoter=(John Purity Boni)
dayOwner=$((10#$(date +%j) % ${#DishesRoter[@]})) # 0 indexing
echo "${DishesRoter[$dayOwner]} to clean dishes"
