bool manualSelectionNeeded = false;
bool blockFound = false;

void FindBlock(CGameCtnEditorCommon@ editor, CGameCtnBlockInfo@ blockInfo, int2 originalPos, int pixelSkip = 2) {
    @editor = cast<CGameCtnEditorCommon@>(GetApp().Editor);
    blockFound = false;

    if (!manualSelectionNeeded) {
        int2 centerPos = int2(screenWidth / 2, screenHeight / 2);
        mouse.Move(centerPos);

        for (int j = 0; j < 3 && !blockFound; j++) {
            mouse.Jiggle(2, 1, 0, "left right");
            if (CheckAndClickBlock(editor, blockInfo)) {
                blockFound = true;
                return;
            }

            mouse.Jiggle(2, 1, 0, "up down");
            if (CheckAndClickBlock(editor, blockInfo)) {
                blockFound = true;
                return;
            }
        }

        array<MouseDirection> directions = {
            MouseDirection::upLeft,
            MouseDirection::up,
            MouseDirection::left,
            MouseDirection::upRight,
            MouseDirection::right,
            MouseDirection::down,
            MouseDirection::downLeft,
            MouseDirection::downRight
        };

        for (uint i = 0; i < directions.Length && !blockFound; i++) {
            if (MoveDirectionWithCheckAndClick(editor, blockInfo, directions[i], screenHeight / 4, pixelSkip)) {
                blockFound = true;
                return;
            }

            mouse.Move(centerPos);
        }

        int chunkWidth = screenWidth / 20;
        int chunkHeight = screenHeight / 20;

        array<int2> chunkOrder;
        int centerX = 10;
        int centerY = 10;

        int x = centerX;
        int y = centerY;
        int dx = 0;
        int dy = -1;
        int maxIters = 400;

        for (int step = 0; step < maxIters; step++) {
            if (x >= 0 && x < 20 && y >= 0 && y < 20) {
                chunkOrder.InsertLast(int2(x, y));
            }

            if ((x == y) || (x > 0 && x == -y) || (x < 0 && x == 1 - y)) {
                int temp = dx;
                dx = -dy;
                dy = temp;
            }

            x += dx;
            y += dy;
        }

        for (uint i = 0; i < chunkOrder.Length && !blockFound; i++) {
            int2 chunk = chunkOrder[i];
            int startX = chunk.x * chunkWidth;
            int startY = chunk.y * chunkHeight;

            mouse.Move(int2(startX + chunkWidth / 2, startY + chunkHeight / 2));
            if (CheckAndClickBlock(editor, blockInfo)) {
                blockFound = true;
                return;
            }

            for (int y = startY; y < startY + chunkHeight && !blockFound; y += pixelSkip) {
                mouse.Move(int2(startX, y));
                if (CheckAndClickBlock(editor, blockInfo)) {
                    blockFound = true;
                    return;
                }

                for (int x = startX; x < startX + chunkWidth && !blockFound; x += pixelSkip) {
                    mouse.MoveRelative(pixelSkip, 0);
                    if (CheckAndClickBlock(editor, blockInfo)) {
                        blockFound = true;
                        return;
                    }

                    yield(1);
                }
            }

            mouse.Move(originalPos);
        }

        if (!blockFound && (editor.PickedBlock is null || editor.PickedBlock.BlockInfo.Name != blockInfo.Name)) {
            log("Unable to find the block, requesting manual selection.", LogLevel::Error, 309, "FindBlock");
            manualSelectionNeeded = true;
            NotifyError("Unable to find the block, please select it manually.");
        }
    }
}

bool CheckAndClickBlock(CGameCtnEditorCommon@ editor, CGameCtnBlockInfo@ blockInfo) {
    if (editor !is null && editor.PickedBlock !is null && editor.PickedBlock.BlockInfo.Name == blockInfo.Name) {
        log("Block found! Confirming selection.", LogLevel::Info, 261, "FindBlock");
        mouse.Click();
        return true;
    }
    return false;
}

bool MoveDirectionWithCheckAndClick(CGameCtnEditorCommon@ editor, CGameCtnBlockInfo@ blockInfo, MouseDirection dir, int distance, int step = 1) {
    int frames = distance / step;
    for (int i = 0; i < frames && !blockFound; i++) {
        mouse.MoveDirectionOverTime(dir, step);
        
        if (CheckAndClickBlock(editor, blockInfo)) {
            blockFound = true;
            return true;
        }

        yield(1);
    }
    return false;
}













// Please ignore, it's my attempt at a more 'dynamic' searching dings, I failed spectacularly xdd

// bool manualSelectionNeeded = false;

// float CalculateNonLinearScalingFactor(int originalValue, float baseScale = 10.0) {
//     return baseScale * Math::Log(float(originalValue) + 1.0);
// }

// void FindBlock(CGameCtnEditorCommon@ editor, CGameCtnBlockInfo@ blockInfo, int2 originalPos) {
//     @editor = cast<CGameCtnEditorCommon@>(GetApp().Editor);

//     if (!manualSelectionNeeded) {
//         float baseScale = 10.0;

//         int[] radii = {1, 2, 3/*, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15*/};
//         int[] frameCounts = {30, 50, 70/*, 90, 110, 130, 150, 170, 190, 210, 230, 250, 270, 290, 310*/};

//         for (uint i = 0; i < radii.Length; i++) {
//             mouse.Move(originalPos);

//             int pixelRadius = int(CalculateNonLinearScalingFactor(radii[i], baseScale));

//             mouse.MoveRelative(-pixelRadius, 0);

//             if (JiggleWithCheck(editor, blockInfo, "circle", 1, frameCounts[i], 1, pixelRadius)) return;

//             mouse.Move(originalPos);
//         }

//         if (editor.PickedBlock is null || editor.PickedBlock.BlockInfo.Name != blockInfo.Name) {
//             log("Unable to find the block, requesting manual selection.", LogLevel::Error, 309, "FindBlock");
//             manualSelectionNeeded = true;
//             NotifyError("Unable to find the block, please select it manually.");
//         }
//     }
// }


// bool JiggleWithCheck(CGameCtnEditorCommon@ editor, CGameCtnBlockInfo@ blockInfo, const string &in type, int step, int frames, int movement, int radius) {
//     @editor = cast<CGameCtnEditorCommon@>(GetApp().Editor);

//     for (int i = 0; i < frames; i++) {
//         mouse.JiggleOverTime(i, frames, step, radius, type);

//         if (editor !is null && editor.PickedBlock !is null && editor.PickedBlock.BlockInfo.Name == blockInfo.Name) {
//             log("Clicking to confirm the selection.", LogLevel::Info, 261, "FindBlock");
//             mouse.Click();
//             return true;
//         }

//         yield(1);
//     }
//     return false; 
// }