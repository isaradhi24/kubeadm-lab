
The "Morning Routine" Automation:
Instead of manually fixing it, let's ensure the service is enabled to start on boot. Run this on the Jenkins VM:

Bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
The Vagrant "Pause":
When you finish for the day, DO NOT use vagrant destroy. Use:

Bash
vagrant suspend  # Saves the exact RAM state to disk
# OR
vagrant halt     # Graceful shutdown
Next morning: vagrant up will bring it back exactly where you left it.

The Fix: Make it Permanent
Check the Persistence: Since we installed Jenkins manually, ensure the data directory is safe. Jenkins keeps everything in /var/lib/jenkins.