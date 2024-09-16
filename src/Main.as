enum Conversion {
    None = 0,
    blockToBlock = 1,
    blockToItem = 2,
    itemToItem = 3,
}

[Setting category="Conversion" name="Conversion Type"]
Conversion currentConversion = Conversion::None;

void aMain() {
    // if (!_Game::IsInEditor()) { log("Not in editor. Exiting.", LogLevel::Error, 12, "Main"); return; }

    PrepareConversion();

    mouse.Move(985, 550);
    print(mouse.GetPosition());

    return;

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
    const string relativeDllPath = "src/lib/MouseControl.dll";
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
    Import::Function@ get_position_x;
    Import::Function@ get_position_y;

    Import::Function@ click;
    Import::Function@ r_click;

    Import::Function@ mouse_down;
    Import::Function@ r_mouse_down;

    Import::Function@ move;
    Import::Function@ move_relative;


    MouseController(Import::Library@ lib) {
        if (lib !is null) {
            // @get_position_x = lib.GetFunction("GetPositionX");
            // @get_position_y = lib.GetFunction("GetPositionY");

            @r_click = lib.GetFunction("RClick");
            @click = lib.GetFunction("Click");

            @move = lib.GetFunction("Move");
            @move_relative = lib.GetFunction("MoveRelative");
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


    int2 GetPosition() {
        return int2(GetPositionX(), GetPositionY());
    }

    private int GetPositionX() {
        if (get_position_x !is null) {
            return get_position_x.CallInt32();
        }
        print("Failed to get position x (get_position_x is null)");
        return 0;
    }

    private int GetPositionY() {
        if (get_position_y !is null) {
            return get_position_y.CallInt32();
        }
        print("Failed to get position y (get_position_y is null)");
        return 0;
    }
    
}