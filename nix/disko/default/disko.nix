{
  disko.devices = {
    disk = {
        one = {
            device = "/dev/sda";
            type = "disk";
            content = {
                type="gpt";
                partitions= {
                    efi = {
                        type = "EF02";
                        size = "512M";
                    };
                    boot = {
                        size = "2G";
                        type = "EF00";
                        content = {
                            type = "filesystem";
                            format = "vfat";
                            mountpoint = "/boot";
                        };
                    };
                    swap = {
                        size = "16G";
                        content = {
                            type = "swap";
                            resumeDevice = true;
                        };
                    };
                    root = {
                        size = "100%";
                        content = {
                            type = "filesystem";
                            format = "ext4";
                            mountpoint = "/";
                        };
                    };
                };
            };
        };
    };
  };
}