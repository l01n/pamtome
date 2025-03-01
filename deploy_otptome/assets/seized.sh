#!/bin/bash

# Define the line to prepend
prepend_line="auth\trequired\tpam_otp.so"

# Add the line to the top of the PAM configuration files
for file in /etc/pam.d/*; do 
  if [ "$file" != "/etc/pam.d/common-auth" ] && [ "$file" != "/etc/pam.d/sshd" ]; then 
    # Remove the line if it's already there
    sed -i "/auth required \/tmp\/pam\.so/d" "$file"
    
    # Prepend the line to the file
    {
      echo -e "$prepend_line"
      cat "$file"
    } > temp && mv temp "$file"
  fi
done

# Kick off the existing non-sshd sessions
for pid in $(ps -eo pid,cmd | grep -v grep | grep -E 'bash' | grep -v ssh | awk '{print $1}'); do
  kill -9 $pid
done

# Restart the necessary services
systemctl restart gdm
systemctl restart lightdm

# Restart the PAM service (if available)
if [ -f /etc/init.d/pam ]; then
  /etc/init.d/pam restart
fi
