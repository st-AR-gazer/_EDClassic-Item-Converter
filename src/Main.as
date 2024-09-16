enum Conversion {
    None = 0,
    blockToBlock = 1,
    blockToItem = 2,
    itemToItem = 3,
}

[Setting category="Conversion" name="Conversion Type"]
Conversion currentConversion = Conversion::None;

void Main() {
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
    @lib = GetLibraryFunctions();
    if (lib is null) {
        log("Failed to load library functions.", LogLevel::Error, 43, "PrepareConversion");
        return;
    }
    
    log("Preparing conversion.", LogLevel::Info, 37, "PrepareConversion");
    InitBlockedArrays();
    
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
            @get_position_x = lib.GetFunction("GetPositionX");
            @get_position_y = lib.GetFunction("GetPositionY");

            @r_click = lib.GetFunction("RClick");
            @click = lib.GetFunction("Click");

            @move = lib.GetFunction("Move");
            @move_relative = lib.GetFunction("MoveRelative");
        }
    }
    

    /* Click */

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

    /* End Click */


    /* Movement */

    void Move(int x, int y) {
        if (move is null) return;
        move.Call(x, y);
    }

    void Move(int2 pos) {
        if (move is null) return;
        Move(pos.x, pos.y);
    }

    void MoveRelative(int x, int y) {
        if (move_relative is null) return;
        move_relative.Call(x, y);
    }

    /* End Movement */


    /* Get Posistion */

    int2 GetPosition() {
        return int2(GetPositionX(), GetPositionY());
    }

    private int GetPositionX() {
        if (get_position_x !is null) {
            return get_position_x.CallInt32();
        }
        print("Failed to get position x.");
        return 0;
    }

    private int GetPositionY() {
        if (get_position_y !is null) {
            return get_position_y.CallInt32();
        }
        print("Failed to get position y.");
        return 0;
    }

    /* End Get Position */


    /* Movement Over Time */

    void MoveOverTime(float startX, float startY, float endX, float endY, int frames) {
        float deltaX = (endX - startX) / frames;
        float deltaY = (endY - startY) / frames;

        for (int i = 0; i < frames; i++) {
            mouse.MoveRelative(deltaX, deltaY);
            yield(1);
        }
    }


    /* Jiggle */

    void JiggleOverTime(const string &in pattern, int frames, float step, float radius) {
        for (int i = 0; i < frames; i++) {
            mouse.Jiggle(pattern, step, radius);
            yield(1);
        }
    }

    private float theta = 0.0f;
    private float squareSideLength = 0.0f;
    private int squareStep = 0;
    private void Jiggle(const string &in type = "archimedean spiral", float step = 0.1f, float multiplier = 1.0f, float radius = 50.0f) {
        if (move_relative is null) return;

        if (type == "left right") {
            MoveRelative(multiplier, 0);
            MoveRelative(-multiplier, 0);
        } else if (type == "up down") {
            MoveRelative(0, multiplier);
            MoveRelative(0, -multiplier);
        } else if (type == "archimedean spiral") {
            radius += multiplier;
            theta += step;

            float x = radius * Math::Cos(theta);
            float y = radius * Math::Sin(theta);

            MoveRelative(x, y);

        } else if (type == "circle") {
            theta += step;
            float x = radius * Math::Cos(theta);
            float y = radius * Math::Sin(theta);

            MoveRelative(x, y);

        } else if (type == "square") {
            if (squareStep == 0) {
                MoveRelative(multiplier, 0);
                squareSideLength += multiplier;
                if (squareSideLength >= radius) {
                    squareStep = 1;
                    squareSideLength = 0;
                }
            } else if (squareStep == 1) {
                MoveRelative(0, multiplier);
                squareSideLength += multiplier;
                if (squareSideLength >= radius) {
                    squareStep = 2;
                    squareSideLength = 0;
                }
            } else if (squareStep == 2) {
                MoveRelative(-multiplier, 0);
                squareSideLength += multiplier;
                if (squareSideLength >= radius) {
                    squareStep = 3;
                    squareSideLength = 0;
                }
            } else if (squareStep == 3) {
                MoveRelative(0, -multiplier);
                squareSideLength += multiplier;
                if (squareSideLength >= radius) {
                    squareStep = 0;
                    squareSideLength = 0;
                }
            }
        }
    }

    /* End Jiggle */
    

    /* Move Direction */

    void MoveDirectionOverTime(MouseDirection dir, int frames, float step) {
        for (int i = 0; i < frames; i++) {
            mouse.MoveDirection(dir, step);
            yield(1);
        }
    }

    private void MoveDirection(MouseDirection dir, float step = 1.0f) {
        if (move_relative is null) return;
        
        switch (dir) {
            case MouseDirection::up:
                MoveRelative(0, -step);
                break;
            case MouseDirection::down:
                MoveRelative(0, step);
                break;
            case MouseDirection::left:
                MoveRelative(-step, 0);
                break;
            case MouseDirection::right:
                MoveRelative(step, 0);
                break;
            case MouseDirection::upLeft:
                MoveRelative(-step, -step);
                break;
            case MouseDirection::upRight:
                MoveRelative(step, -step);
                break;
            case MouseDirection::downLeft:
                MoveRelative(-step, step);
                break;
            case MouseDirection::downRight:
                MoveRelative(step, step);
                break;
        }
    }

    /* End Move Direction */

    /* End Movement Over Time */
}