#!/bin/bash
# DishesRoter=(Purity John Boni)
DishesRoter=(Boni John)
dayOwner=$((10#$(date +%j) % ${#DishesRoter[@]})) # 0 indexing
echo "${DishesRoter[$dayOwner]} to clean dishes"
