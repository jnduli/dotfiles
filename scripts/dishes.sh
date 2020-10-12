#!/bin/bash
DishesRoter=(Purity John Boni)
dayOwner=$(($(date +%j) % 3)) # 0 indexing
echo "${DishesRoter[$dayOwner]} to clean dishes"
