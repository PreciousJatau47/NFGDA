import nexradaws
import os
from datetime import datetime
import sys

aws_int = nexradaws.NexradAwsInterface()
radar_id = 'KAMA'
year, mth, day = 2024, 2, 28
start_hr, start_min = 0, 0
end_hr, end_min = 2, 18

start = datetime(year, mth, day, start_hr, start_min)
end = datetime(year, mth, day, end_hr, end_min)

dest_base = r"../../V06"
# dest_base = r"./V06"
dest_folder = '{}{}{:02}{:02}_{:02}'.format(radar_id, year, mth, day, start_hr)
dest = os.path.join(dest_base, dest_folder)
dest = os.path.normpath(dest)

if not os.path.isdir(dest):
    os.makedirs(dest)
else:
    sys.exit('{} already exists.'.format(dest_folder))

scans = aws_int.get_avail_scans_in_range(start, end, radar_id)
aws_int.download(scans, dest)