import argparse
import sys
from plexapi.server import PlexServer

def main():
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(
        description="Convert a Plex music playlist into a shared Plex collection using command-line parameters."
    )
    
    parser.add_argument('--url', required=True, help="Your Plex Server URL (e.g., http://localhost:32400)")
    parser.add_argument('--token', required=True, help="Your Plex Authentication Token (X-Plex-Token). If your server is on Windows, regedit the 'PlexOnlineToken' value in 'HKEY_CURRENT_USER\\Software\\Plex, Inc.\\Plex Media Server'.")
    parser.add_argument('--playlist', required=True, help="The exact name of the Playlist you want to convert")
    parser.add_argument('--library', default="Music", help="The name of your Plex Music library (Defaults to 'Music')")
    parser.add_argument('--collection', help="Optional: Name of the output Collection (Defaults to the Playlist name)")

    args = parser.parse_args()

    # Fallback collection name if none provided
    collection_name = args.collection if args.collection else args.playlist

    print("Connecting to Plex Server...")
    try:
        plex = PlexServer(args.url, args.token)
    except Exception as e:
        print(f"Error connecting to server. Check your URL and Token. Details: {e}")
        sys.exit(1)

    try:
        # 1. Locate the playlist
        print(f"Finding playlist: '{args.playlist}'...")
        playlist = plex.playlist(args.playlist)
        playlist_items = playlist.items()
        
        if not playlist_items:
            print("The playlist is empty or could not be read.")
            sys.exit(1)
            
        print(f"Found {len(playlist_items)} tracks in the playlist.")

        # 2. Connect to the specified library
        music_library = plex.library.section(args.library)

        # 3. Initialize/Create the collection with the first track
        print(f"Creating/Updating Collection: '{collection_name}'...")
        first_track = playlist_items[0]
        collection = music_library.createCollection(
            title=collection_name, 
            items=first_track
        )
        
        # 4. Bulk add the remaining tracks
        if len(playlist_items) > 1:
            remaining_tracks = playlist_items[1:]
            collection.addItems(remaining_tracks)
            
        print(f"Success! Successfully converted '{args.playlist}' into the collection '{collection_name}'.")

    except Exception as e:
        print(f"An error occurred during processing: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
