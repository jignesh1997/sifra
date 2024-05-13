import 'dart:io';

Future<void> executeShellScript(String scriptPath) async {
  try {
    // Check if the script file exists
    if (!File(scriptPath).existsSync()) {
      print('Shell script not found: $scriptPath');
      return;
    }

    // Make the script executable
    await Process.run('chmod', ['+x', scriptPath]);

    // Execute the shell script
    ProcessResult result = await Process.run(scriptPath, []);

    // Print the output
    print('Script output:');
    print(result.stdout);

    // Check if there was an error
    if (result.exitCode != 0) {
      print('Script execution failed with exit code: ${result.exitCode}');
      print('Error message:');
      print(result.stderr);
    } else {
      print('Script executed successfully');
    }
  } catch (e) {
    print('Error executing shell script: $e');
  }
}