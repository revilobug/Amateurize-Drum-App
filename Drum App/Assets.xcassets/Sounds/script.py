import os

def rename_wav_files():
    # Get the current directory
    current_directory = os.getcwd()

    # Iterate through all items in the current directory
    for item in os.listdir(current_directory):
        item_path = os.path.join(current_directory, item)
        
        # Check if the item is a directory and ends with ".dataset"
        if os.path.isdir(item_path) and item.endswith(".dataset"):
            # The new file name should be the same as the directory name (without the .dataset part)
            new_file_name = item.replace(".dataset", "")
            wav_file_found = False

            # Iterate through the files inside the .dataset folder
            for file in os.listdir(item_path):
                if file.endswith(".wav"):
                    wav_file_path = os.path.join(item_path, file)
                    new_wav_file_path = os.path.join(item_path, new_file_name + ".wav")
                    
                    # Rename the .wav file
                    os.rename(wav_file_path, new_wav_file_path)
                    print(f"Renamed {wav_file_path} to {new_wav_file_path}")
                    wav_file_found = True
                    break  # Assuming there is only one .wav file per folder
            
            if not wav_file_found:
                print(f"No .wav file found in {item_path}")

if __name__ == "__main__":
    rename_wav_files()
