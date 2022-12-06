#!/bin/bash
# I have 1.75 days of PTO per year
# Roll over happens for 8 days per yeear
# I'm looking for a way to automatically notify myself when I need to have more fere dayads.
# I can set this script up in my server ahd have an email sent out whenever my days exceed 5 days, so that I can schedule more.

# Perhaps do a daemon with this, let's see how this would work.

# PTO_Days_taken, I need to update this every time I take days off
PTO_days_taken=21
Sick_off_days_taken=0

Sick_off_days=14

previous_years_carried_over_days=8

# approximation since bash doesn't handle floats
accumulated_days=$((175 * $(date +%-m) / 100 ))

untaken_pto_days=$(( previous_years_carried_over_days + accumulated_days - PTO_days_taken ))
untaken_sick_off=$(( Sick_off_days - Sick_off_days_taken ))
echo "Please schedule following days for PTO: " $untaken_pto_days
echo "If sick, I have the following days: " $untaken_sick_off
