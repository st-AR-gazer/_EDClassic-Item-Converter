namespace BlockToItem {
    Utils@ utils;
    Conversion@ conv;

    int totalBlocks = 0;
    int totalBlocksConverted = 0;
    
    array<CGameCtnBlockInfo@> indexedBlocks;
    array<string> saveLocations;
    
    dictionary completedBlocks;

    void Init() {
        log("Initializing BlockToItem.", LogLevel::Info, 9, "Init");

        @utils = Utils();
        @conv = Conversion();

        // Load cached completed blocks
        string[] completedFiles = IO::IndexFolder(IO::FromUserGameFolder("Items/VanillaBlockToCustomItem"), true);
        for (uint i = 0; i < completedFiles.Length; i++) {
            string withBlock = Path::GetFileNameWithoutExtension(completedFiles[i]);
            string completedBlockName = Path::GetFileNameWithoutExtension(withBlock);
            completedBlocks[completedBlockName.ToLower()] = true;
        }

        ConversionPreparation();
    }

    void ConversionPreparation() {
        log("Converting block to item.", LogLevel::Info, 18, "ConversionPreparation");
        
        CGameCtnApp@ app = GetApp();
        CGameCtnEditorCommon@ editor = cast<CGameCtnEditorCommon@>(app.Editor);
        CGameEditorPluginMapMapType@ pmt = editor.PluginMapType;
        CGameEditorGenericInventory@ inventory = pmt.Inventory;

        CGameCtnArticleNodeDirectory@ blocksNode = cast<CGameCtnArticleNodeDirectory@>(inventory.RootNodes[0]);
        totalBlocks = utils.CountBlocks(blocksNode, false, true);

        ExploreNode(blocksNode);

        ProcessIndexedBlocks();
    }

    void ExploreNode(CGameCtnArticleNodeDirectory@ parentNode, string _folder = "") {
        for (uint i = 0; i < parentNode.ChildNodes.Length; i++) {
            auto node = parentNode.ChildNodes[i];
            if (node.IsDirectory) {
                ExploreNode(cast<CGameCtnArticleNodeDirectory@>(node), _folder + node.Name + "/");
            } else {
                auto ana = cast<CGameCtnArticleNodeArticle@>(node);
                if (ana.Article is null || ana.Article.IdName.ToLower().EndsWith("customblock")) {
                    log("Skipping block " + ana.Name + " because it's a custom block.", LogLevel::Info, 38, "ExploreNode");
                    continue;
                }

                auto block = cast<CGameCtnBlockInfo@>(ana.Article.LoadedNod);
                if (block is null || IsBlockCompleted(block.Name)) {
                    continue;
                }

                if (string(block.Name).ToLower().Contains("water")) {
                    log("Water cannot be converted to a custom block/item. Skipping.", LogLevel::Info, 59, "ExploreNode");
                    continue;
                }

                if (utils.IsBlacklisted(block.Name)) {
                    log("Block " + block.Name + " is blacklisted. Skipping.", LogLevel::Info, 64, "ExploreNode");
                    continue;
                }

                string itemSaveLocation = "VanillaBlockToCustomItem/" + _folder + block.Name + ".Item.Gbx";
                indexedBlocks.InsertLast(block);
                saveLocations.InsertLast(itemSaveLocation);

                totalBlocksConverted++;
            }
        }
    }

    bool IsBlockCompleted(const string &in blockName) {
        return completedBlocks.Exists(blockName.ToLower());
    }

    void ProcessIndexedBlocks() {
        for (uint i = 0; i < indexedBlocks.Length; i++) {
            CGameCtnBlockInfo@ block = indexedBlocks[i];
            string itemSaveLocation = saveLocations[i];
            string fullItemSaveLocation = IO::FromUserGameFolder("Items/" + itemSaveLocation);

            if (!IO::FileExists(fullItemSaveLocation)) {
                log("Converting and saving block to item: " + block.Name, LogLevel::Info, 135, "ProcessIndexedBlocks");
                conv.ConvertBlockToItem(block, itemSaveLocation);
            } else {
                log("Item already exists, skipping: " + block.Name, LogLevel::Info, 138, "ProcessIndexedBlocks");
            }
        }
    }

    class Conversion {
        int2 button_Icon = int2(445, 417);
        int2 button_DirectionIcon = int2(985, 550);

        void ConvertBlockToItem(CGameCtnBlockInfo@ blockInfo, const string &in itemSaveLocation) {
            log("Converting block to item.", LogLevel::Info, 82, "ConvertBlockToItem");

            auto app = GetApp();
            auto editor = cast<CGameCtnEditorCommon@>(app.Editor);
            auto pmt = editor.PluginMapType;

            yield();

            pmt.PlaceMode = CGameEditorPluginMap::EPlaceMode::GhostBlock;

            yield();

            @pmt.CursorBlockModel = blockInfo;

            yield();

            int nBlocks = pmt.Blocks.Length;
            log("Starting to place the block: " + blockInfo.Name, LogLevel::Info, 103, "ConvertBlockToItem");
            while (pmt.Blocks.Length == uint(nBlocks)) {
                mouse.Click();
                yield();
            }

            editor.ButtonItemCreateFromBlockModeOnClick();

            yield();

            while (cast<CGameEditorItem>(app.Editor) is null) {
                @editor = cast<CGameCtnEditorCommon@>(app.Editor);
                if (editor !is null && editor.PickedBlock !is null && editor.PickedBlock.BlockInfo.IdName == blockInfo.Name) {
                    log("Clicking to confirm selection.", LogLevel::Info, 116, "ConvertBlockToItem");
                    mouse.Jiggle();
                    mouse.Click();
                }
                yield();
            }

            log("Clicking the button to set the icon.", LogLevel::Info, 123, "ConvertBlockToItem");
            mouse.Move(button_Icon);
            mouse.Click();

            yield();

            log("Clicking the button to set the direction icon.", LogLevel::Info, 129, "ConvertBlockToItem");
            mouse.Move(button_DirectionIcon);
            mouse.Click();

            yield();

            log("Saving item to: " + itemSaveLocation, LogLevel::Info, 135, "ConvertBlockToItem");
            CGameEditorItem@ editorItem = cast<CGameEditorItem>(app.Editor);
            editorItem.IdName = blockInfo.Name;
            editorItem.PlacementParamGridHorizontalSize = 32;
            editorItem.PlacementParamGridVerticalSize = 8;
            editorItem.PlacementParamFlyStep = 8;
            editorItem.FileSaveAs();

            yield(3);

            app.BasicDialogs.String = itemSaveLocation;

            yield();

            app.BasicDialogs.DialogSaveAs_OnValidate();

            yield();

            app.BasicDialogs.DialogSaveAs_OnValidate();

            yield();

            cast<CGameEditorItem>(app.Editor).Exit();

            while (cast<CGameEditorItem>(app.Editor) !is null) {
                yield();
            }

            yield();

            mouse.Move(int2(screenHeight / 2, screenWidth / 2));

            @editor = cast<CGameCtnEditorCommon@>(app.Editor);
            @pmt = editor.PluginMapType;
            pmt.Undo();

        }
    }

    class Utils {
        bool IsBlacklisted(const string &in blockName) {
            for (uint i = 0; i < blockToItemBlacklist.Length; i++) {
                if (blockName.Contains(blockToItemBlacklist[i])) {
                    return true;
                }
            }
            return false;
        }

        int CountBlocks(CGameCtnArticleNodeDirectory@ parentNode, bool justNadeoBlocks = true, bool containsWater = false) {
            int count = 0;
            for (uint i = 0; i < parentNode.ChildNodes.Length; i++) {
                CGameCtnArticleNode@ node = parentNode.ChildNodes[i];
                if (node.IsDirectory) {
                    count += CountBlocks(cast<CGameCtnArticleNodeDirectory@>(node), justNadeoBlocks);
                } else {
                    CGameCtnBlock@ block = cast<CGameCtnBlock@>(node);
                    if (justNadeoBlocks && block.BlockInfo.Name.Contains("customblock")) {
                        continue;
                    }
                    count++;
                }
            }
            return count;
        }

        int BlocksLeftToConvert() {
            return totalBlocks - totalBlocksConverted;
        }

        void FindBlock(CGameCtnEditorCommon@ editor, CGameCtnBlockInfo@ blockInfo, int2 originalPos) {
            @editor = cast<CGameCtnEditorCommon@>(GetApp().Editor);

            mouse.JiggleOverTime("left right", 20, 0.1f, 10.0f);

            if (editor !is null && editor.PickedBlock !is null && editor.PickedBlock.BlockInfo.Name == blockInfo.Name) {
                log("Clicking to confirm the selection.", LogLevel::Info, 261, "FindBlock");
                mouse.Click();
                yield(10);
            } else {
                log("Moving to original position.", LogLevel::Info, 265, "FindBlock");
                mouse.Move(originalPos);

                log("Trying directional movement.", LogLevel::Info, 268, "FindBlock");
                mouse.MoveDirectionOverTime(MouseDirection::downLeft, 20, 10.0f);
                mouse.Move(originalPos);
                mouse.MoveDirectionOverTime(MouseDirection::left, 20, 10.0f);
                mouse.Move(originalPos);
                mouse.MoveDirectionOverTime(MouseDirection::upLeft, 20, 10.0f);
                mouse.Move(originalPos);
                mouse.MoveDirectionOverTime(MouseDirection::up, 20, 10.0f);
                mouse.Move(originalPos);
                mouse.MoveDirectionOverTime(MouseDirection::upRight, 20, 10.0f);
                mouse.Move(originalPos);
                mouse.MoveDirectionOverTime(MouseDirection::right, 20, 10.0f);
                mouse.Move(originalPos);
                mouse.MoveDirectionOverTime(MouseDirection::downRight, 20, 10.0f);
                mouse.Move(originalPos);
                mouse.MoveDirectionOverTime(MouseDirection::down, 20, 10.0f);
                mouse.Move(originalPos);

                log("Trying circle jiggle pattern.", LogLevel::Info, 286, "FindBlock");
                mouse.JiggleOverTime("circle", 20, 0.1f, 10.0f);
                mouse.Move(originalPos);
                mouse.JiggleOverTime("circle", 20, 0.1f, 20.0f);
                mouse.Move(originalPos);
                mouse.JiggleOverTime("circle", 20, 0.1f, 30.0f);
                mouse.Move(originalPos);
                mouse.JiggleOverTime("circle", 20, 0.1f, 40.0f);
                mouse.Move(originalPos);
                mouse.JiggleOverTime("circle", 20, 0.1f, 50.0f);
                mouse.Move(originalPos);

                log("Trying spiral jiggle pattern.", LogLevel::Info, 298, "FindBlock");
                mouse.JiggleOverTime("archimedean spiral", 20, 0.1f, 1.0f);
                mouse.Move(originalPos);
                mouse.JiggleOverTime("archimedean spiral", 20, 0.1f, 2.0f);
                mouse.Move(originalPos);
                mouse.JiggleOverTime("archimedean spiral", 20, 0.1f, 3.0f);
                mouse.Move(originalPos);
                mouse.JiggleOverTime("archimedean spiral", 20, 0.1f, 4.0f);
                mouse.Move(originalPos);

                if (editor.PickedBlock is null || editor.PickedBlock.BlockInfo.Name != blockInfo.Name) {
                    log("Unable to find the block, requesting manual selection.", LogLevel::Error, 309, "FindBlock");
                    ShowManualSelectionUI();
                }
            }
        }

        void ShowManualSelectionUI() {
            log("Showing manual selection UI.", LogLevel::Info, 316, "ShowManualSelectionUI");
            NotifyError("Unable to find the block, please select it manually.");
        }
    }
}
