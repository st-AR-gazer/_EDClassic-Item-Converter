enum Conversion {
    None = 0,
    blockToBlock = 1,
    blockToItem = 2,
    itemToItem = 3,
}

[Setting category="Conversion" name="Conversion Type"]
Conversion currentConversion = Conversion::None;

void Main() {
    if (!_Game::IsInEditor()) { log("Not in editor. Exiting.", LogLevel::Error, 12, "Main"); return; }

    PrepareConversion();

    if (currentConversion == Conversion::None) { log("No conversion type selected. Exiting.", LogLevel::Error, 16, "Main"); return; }
    if (currentConversion == Conversion::blockToBlock) {
        BlockToBlock::Init();
    } else if (currentConversion == Conversion::blockToItem) {
        BlockToItem::Init();
    } else if (currentConversion == Conversion::itemToItem) {
        ItemToItem::Init();
    }
}





int screenHeight = 0;
int screenWidth = 0;

Import::Library@ lib = null;
MouseController@ mouse = null;

void PrepareConversion() {
    log("Preparing conversion.", LogLevel::Info, 37, "PrepareConversion");
    
    InitBlockedArrays();

    @lib = GetLibraryFunctions();
    if (lib is null) {
        log("Failed to load library functions.", LogLevel::Error, 43, "PrepareConversion");
        return;
    }
    
    @mouse = MouseController(lib);

    screenHeight = Draw::GetHeight();
    screenWidth = Draw::GetWidth();

    log("Screen Dimensions: " + screenWidth + "x" + screenHeight, LogLevel::Info, 52, "PrepareConversion");
}

Import::Library@ GetLibraryFunctions() {
    const string relativeDllPath = "src/lib/mouseControl.dll";
    const string baseFolder = IO::FromDataFolder('');
    const string localDllFile = baseFolder + relativeDllPath;

    if (!IO::FileExists(localDllFile)) {
        IO::CreateFolder(Path::GetDirectoryName(localDllFile));

        try {
            IO::FileSource zippedDll(relativeDllPath);
            IO::File toItem(localDllFile, IO::FileMode::Write);
            toItem.Write(zippedDll.Read(zippedDll.Size()));
            toItem.Close();
        } catch {
            return null;
        }
    }

    return Import::GetLibrary(localDllFile);
}





enum MouseDirection {
    none = 0,

    up = 1,
    down = 2,
    left = 3,
    right = 4,

    upLeft = 5,
    upRight = 6,
    downLeft = 7,
    downRight = 8
}

class MouseController {
    Import::Function@ get_position;
    Import::Function@ click;
    Import::Function@ move;

    MouseController(Import::Library@ lib) {
        if (lib !is null) {
            @get_position = lib.GetFunction("GetPosition");
            @click = lib.GetFunction("Click");
            @move = lib.GetFunction("Move");
        }
    }


    void Click() {
        if (click is null) return;
        click.Call();
    }

    void Click(int x, int y) {
        if (click is null) return;

        Move(x, y);
        Click();
    }

    void Click(int2 pos) {
        if (click is null) return;
        
        Move(pos);
        Click();
    }

    void Move(int x, int y) {
        if (move is null) return;
        move.Call(x, y);
    }

    void Move(int2 pos) {
        if (move is null) return;
        Move(pos.x, pos.y);
    }

    array<int> GetPosition() {
        if (get_position is null) {
            int2 position = get_position.CallInt64();
            return {position.x, position.y};
        }
        return {0, 0};
    }

    void Jiggle(float multiplier = 1.0f, int direction = 0) {
        if (move is null) return;

        array<int> pos = GetPosition();
        switch (direction) {
            case 0: // No rotation
                Move(pos[0] + (1 * multiplier), pos[1]);
                Move(pos[0], pos[1] + (1 * multiplier));
                Move(pos[0] - (1 * multiplier), pos[1]);
                Move(pos[0], pos[1] - (1 * multiplier));
                break;
            case 1: // Rotate clockwise
                Move(pos[0] + (1 * multiplier), pos[1]);
                Move(pos[0], pos[1] + (1 * multiplier));
                Move(pos[0] - (1 * multiplier), pos[1]);
                Move(pos[0], pos[1] - (1 * multiplier));
                break;
            case 2: // Rotate counterclockwise
                Move(pos[0] - (1 * multiplier), pos[1]);
                Move(pos[0], pos[1] + (1 * multiplier));
                Move(pos[0] + (1 * multiplier), pos[1]);
                Move(pos[0], pos[1] - (1 * multiplier));
                break;
            default:
                break;
        }
    }

    void MoveDirection(MouseDirection dir) {
        if (move is null) return;
        array<int> pos = GetPosition();
        switch (dir) {
            case MouseDirection::up:
                Move(pos[0], pos[1] - 1);
                break;
            case MouseDirection::down:
                Move(pos[0], pos[1] + 1);
                break;
            case MouseDirection::left:
                Move(pos[0] - 1, pos[1]);
                break;
            case MouseDirection::right:
                Move(pos[0] + 1, pos[1]);
                break;
            case MouseDirection::upLeft:
                Move(pos[0] - 1, pos[1] - 1);
                break;
            case MouseDirection::upRight:
                Move(pos[0] + 1, pos[1] - 1);
                break;
            case MouseDirection::downLeft:
                Move(pos[0] - 1, pos[1] + 1);
                break;
            case MouseDirection::downRight:
                Move(pos[0] + 1, pos[1] + 1);
                break;
        }
    }
}