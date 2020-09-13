
Vanilla Terraria server running within a docker container


## Quickstart

Below command starts a terraria container with default values

```docker run -d --name terraria-server -p 7777:7777 kevinchanaka/terraria```

Once server is running, terraria command line can be accessed with the following command. Exit the server command line with Control-C

```docker exec -it terraria-server attach```

## Configuration

### Using Environment Variables

The following environment variables are supported. These can be passed via the ``-e`` flag.

|  Variable | Default Value  | Description  |
|---|---|---|
| WORLD_FILE_NAME  | world.wld  | Name of the world file to load. If the file does not exist in the "worlds" directory, a world will be automatically created with the same file name  |
| WORLD | world  | Sets the name of the world when it is auto created  |
| AUTOCREATE | 3 | Size of the world to create if required, will create a large world by default  |
| DIFFICULTY  | 0 | Sets server difficulty when world is auto created, set to 0 (normal) by default  |
| MAX_PLAYERS | 8 | Maximum number of players that can join the server  |
| MOTD | Please don't cut the purple trees!  | Message of the day  |
| LANGUAGE | en-US | Server language  |
| PASSWORD | p@55w0rd* | Server password, recommend changing this value |

```docker run -d --name terraria-server -p 7777:7777 -e AUTOCREATE=1 -e PASSWORD=<YOUR_PASSWORD> kevinchanaka/terraria```

### Using Configuration File

Prepare a directory on your system for terraria server files. This directory must be writable by a user with a UID of 1000. Below examples assume that a folder called "terraria-data" will be created.

```bash
mkdir terraria-data 
sudo chown 1000:1000 terraria-data
```

The contents of this directory should have a `serverconfig.txt` and optionally a `banlist.txt` file within a subdirectory called `config`. If a `serverconfig.txt` file does not exist, the container will create and write a default configuration to the required directory. Please refer below for full directory structure and a sample `serverconfig.txt` file. For more information, refer to the official Terraria server configuration [documentation](https://terraria.gamepedia.com/Server#Server_config_file)

```
# Directory structure

terraria-data
├── config
│   ├── serverconfig.txt
│   └── banlist.txt # optional, container will create a blank file if not found
├── worlds # optional, only required if specifying an existing server file. Otherwise, container will create this directory and contents
│   ├── world.wld 
```

```    
# Sample serverconfig.txt

# NOTES
# for the "world" parameter, a world within the "worlds" directory should be specified
# do not change the value of the "worldpath" parameter

world=worlds/world.wld 
worldpath=worlds 
worldname=world
autocreate=3
difficulty=0
maxplayers=8
motd=Please don’t cut the purple trees!
password=p@55w0rd* 
banlist=config/banlist.txt
language=en-US
```

Once the directory has been created, it can be used as a bind mount to save persistent data. The `serverconfig.txt` file can also be changed and `docker restart` can be used to pick up the changes. 

```docker run -d --name terraria-server -p 7777:7777 -v "$(pwd)"/terraria-data:/app/data kevinchanaka/terraria```
