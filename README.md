# Windows Sensor Monitoring with Telegraf (+ InfluxDB) and Libre Hardware Monitor

References:

- [How to enable CPU temperature monitoring with Telegraf on Windows 11](https://jun1okamura.medium.com/how-to-enable-cpu-temperature-monitoring-with-telegraf-on-windows-11-8dd8c0140bb0)
- [Install Telegraf](https://docs.influxdata.com/telegraf/v1/install/?t=Windows#download-and-install-telegraf)

## Step-by-Step Guide

1. Download the latest version of [Libre Hardware Monitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor/releases).

2. Download the latest version of the [Telegraf](https://docs.influxdata.com/telegraf/v1/install/?t=Windows#download-and-install-telegraf).

3. Download the latest version of [NSSM](https://nssm.cc/download).

   We'll be using NSSM to create a service for the Libre Hardware Monitor. If you prefer setting it up another way, you can skip this step and others related to NSSM.

4. Create a folder to store the programs (In this guide, we'll use `C:\Program Files\Telegraf`).

5. Unzip both programs into the newly created folder.

   For NSSM, you only need the nssm.exe for x64 systems. There’s no need to extract the other files.

   For Libre Hardware Monitor (LHM), create a folder named LHM inside the folder from step 4, then extract the downloaded zip file into it.

6. Open PowerShell as Administrator.

   1. Navigate to the folder created in step `4`.

   2. Install the LHM as service:

      On PowerShell, run:

      ```powershell
      .\nssm install LibreHardwareMonitor
      ```

      1. In the NSSM window, on the first tab, under the `Path` field, click the button at the end of the line to browse for a file.

      2. Navigate to the folder where you extracted LHM and select the main executable (`LibreHardwareMonitor.exe`).

      3. Optionaly, you can go to tab `Process` tab and set the service priority to `Low`

      4. Finish the service configuration by clicking `Install service`.

      5. Open the Service Manager (or Task Manager) and start the newly created service.

   3. Verify if the service is running by executing the script:

      ```powershell
      .\collect_sensors.ps1
      ```

      If the script doesn't show any sensor data, check if the service is running.

7. Configure Telegraf according to your requirements.

8. In the Telegraf configuration file, add the following to call the script that collects LHM metrics:

   ```
   [[inputs.exec]]
       commands = ['powershell -executionpolicy bypass -File "C:\Program Files\Telegraf\collect_sensors.ps1"']
       data_format = "influx"
   ```

9. Install Telegraf as a service by running the following command:

   ```powershell
   .\telegraf --config "C:\Program Files\Telegraf\telegraf.conf" service install
   ```

10. You’re done!
