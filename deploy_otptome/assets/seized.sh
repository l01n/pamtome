#!/bin/bash

prepend_line="auth\trequired\t/tmp/pam_otp.so"

for file in /etc/pam.d/*; do 
  if [ "$file" != "/etc/pam.d/common-auth" ] && [ "$file" != "/etc/pam.d/sshd" ]; then 
    sed -i "/auth required \/tmp\/pam\.so/d" "$file"
    
    {
      echo -e "$prepend_line"
      cat "$file"
    } > temp && mv temp "$file"
  fi
done

if [ -f /etc/init.d/pam ]; then
  echo "Restarting PAM service..."
  /etc/init.d/pam restart
fi

