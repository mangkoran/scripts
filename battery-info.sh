#!/usr/bin/env bash

get_time_until_charged() {

    # parses acpitool's battery info for the remaining charge of all batteries and sums them up
    sum_remaining_charge=$(acpitool -B | grep -E 'Remaining capacity' | awk '{print $4}' | grep -Eo "[0-9]+" | paste -sd+ | bc);

    # finds the rate at which the batteries being drained at
    present_rate=$(acpitool -B | grep -E 'Present rate' | awk '{print $4}' | grep -Eo "[0-9]+" | paste -sd+ | bc);

    # divides current charge by the rate at which it's falling, then converts it into seconds for `date`
    seconds=$(bc <<< "scale = 10; ($sum_remaining_charge / $present_rate) * 3600");

    # prettifies the seconds into h:mm:ss format
    pretty_time=$(date -u -d @${seconds} +%T);

    echo $pretty_time;
}

get_battery_combined_percent() {

    # get charge of all batteries, combine them
    total_charge=$(expr $(acpi -b | awk '{print $4}' | grep -Eo "[0-9]+" | paste -sd+ | bc));

    # get amount of batteries in the device
    battery_number=$(acpi -b | wc -l);

    percent=$(expr $total_charge / $battery_number);

    echo $percent;
}

get_battery_charging_status() {

    if $(acpi -b | grep --quiet Discharging)
    then
        echo "Discharging";
    else # acpi can give Unknown or Charging if charging, https://unix.stackexchange.com/questions/203741/lenovo-t440s-battery-status-unknown-but-charging
        echo "Charging";
    fi
}

echo "All batteries: $(get_battery_charging_status) $(get_battery_combined_percent)%, $(get_time_until_charged ) remaining";
