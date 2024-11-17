bool manualSelectionNeeded = false;
bool blockFound = false;

[Setting category="Conversion" name="yield time" min="0" max="20"]
int S_yieldTime = 5;

array<int2> GenerateSpiralOrder(int gridSize, int centerX, int centerY) {
    array<int2> spiralOrder;
    spiralOrder.InsertLast(int2(centerX, centerY));

    int step = 1;
    int x = centerX;
    int y = centerY;

    while (spiralOrder.Length < gridSize * gridSize) {
        // Move left
        for (int i = 0; i < step; i++) {
            x -= 1;
            if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
                spiralOrder.InsertLast(int2(x, y));
            }
        }

        // Move up
        for (int i = 0; i < step; i++) {
            y -= 1;
            if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
                spiralOrder.InsertLast(int2(x, y));
            }
        }

        step += 1;

        // Move right
        for (int i = 0; i < step; i++) {
            x += 1;
            if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
                spiralOrder.InsertLast(int2(x, y));
            }
        }

        // Move down
        for (int i = 0; i < step; i++) {
            y += 1;
            if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
                spiralOrder.InsertLast(int2(x, y));
            }
        }

        step += 1;
    }

    return spiralOrder;
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

        yield(S_yieldTime);
    }
    return false;
}

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
            auto startTime = Time::Now;
            while (Time::Now - startTime < 3 * 1000) {
                if (MoveDirectionWithCheckAndClick(editor, blockInfo, directions[i], screenHeight / 4, pixelSkip)) {
                    blockFound = true;
                    return;
                }
            }
            mouse.Move(centerPos);
        }

        int gridSize = 5;
        int chunkWidth = screenWidth / gridSize;
        int chunkHeight = screenHeight / gridSize;

        array<int2> chunkOrder = GenerateSpiralOrder(gridSize, gridSize / 2, gridSize / 2);

        for (uint i = 0; i < chunkOrder.Length && !blockFound; i++) {
            int2 chunk = chunkOrder[i];
            int startX = chunk.x * chunkWidth;
            int startY = chunk.y * chunkHeight;

            int2 chunkCenter = int2(startX + chunkWidth / 2, startY + chunkHeight / 2);
            mouse.Move(chunkCenter);

            mouse.Jiggle(2, 1, 0, "left right");
            mouse.Jiggle(2, 1, 0, "up down");

            if (CheckAndClickBlock(editor, blockInfo)) {
                blockFound = true;
                return;
            }

            auto startTime = Time::Now;
            for (int y = startY; y < startY + chunkHeight && !blockFound; y += pixelSkip) {
                if (Time::Now - startTime >= 15 * 1000) break;
                int2 lineStartPos = int2(startX, y);
                mouse.Move(lineStartPos);

                for (int x = startX; x < startX + chunkWidth && !blockFound; x += pixelSkip) {
                    mouse.MoveRelative(pixelSkip, 0);
                    if (CheckAndClickBlock(editor, blockInfo)) {
                        blockFound = true;
                        return;
                    }

                    yield(S_yieldTime);
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
