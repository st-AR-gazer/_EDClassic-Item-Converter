namespace BlockToBlock {
    Utils@ utils;
    Conversion@ conv;

    int totalBlocks = 0;
    int totalBlocksConverted = 0;

    array<CGameCtnBlockInfo@> indexedBlocks;
    array<string> saveLocations;

    dictionary completedBlocks;

    void Init() {
        log("Initializing BlockToBlock.", LogLevel::Info, 14, "Init");

        @utils = Utils();
        @conv = Conversion();

        string[] completedFiles = IO::IndexFolder(IO::FromUserGameFolder("Blocks/VanillaBlockToCustomBlock"), true);
        for (uint i = 0; i < completedFiles.Length; i++) {
            string withBlock = Path::GetFileNameWithoutExtension(completedFiles[i]);
            string completedBlockName = Path::GetFileNameWithoutExtension(withBlock);
            completedBlocks[completedBlockName.ToLower()] = true;
        }

        ConversionPreparation();
    }

    void ConversionPreparation() {
        log("Converting block to block.", LogLevel::Info, 30, "ConversionPreparation");

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
                    continue;
                }
                auto block = cast<CGameCtnBlockInfo@>(ana.Article.LoadedNod);

                if (block is null) {
                    continue;
                }

                if (string(block.Name).ToLower().Contains("water")) {
                    continue;
                }

                if (utils.IsBlacklisted(block.Name)) {
                    continue;
                }

                if (IsBlockCompleted(block.Name)) {
                    continue;
                }

                string blockSaveLocation = "VanillaBlockToCustomBlock/" + _folder + block.Name + ".Block.Gbx";
                indexedBlocks.InsertLast(block);
                saveLocations.InsertLast(blockSaveLocation);

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
            string blockSaveLocation = saveLocations[i];
            string fullBlockSaveLocation = IO::FromUserGameFolder("Blocks/" + blockSaveLocation);

            if (!IO::FileExists(fullBlockSaveLocation)) {
                print("Converting and saving block: " + block.Name);
                log("There are " + utils.BlocksLeftToConvert() + " blocks left to convert.", LogLevel::InfoG, 33, "ConversionPreparation");
                conv.ConvertBlockToBlock(block, blockSaveLocation);
            } else {
                print("Block already exists, skipping: " + block.Name);
            }
        }
    }

    class Conversion {
        int2 button_Icon = int2(445, 255);
        int2 button_DirectionIcon = int2(985, 550);

        int2 button_addMesh = int2(440, 420);
        int2 button_exitMesh = int2(30, 1050);

        void ConvertBlockToBlock(CGameCtnBlockInfo@ blockInfo, const string &in blockSaveLocation) {
            log("Converting block to block.", LogLevel::Info, 110, "ConvertBlockToBlock");

            CGameCtnApp@ app = GetApp();
            CGameCtnEditorCommon@ editor = cast<CGameCtnEditorCommon@>(app.Editor);
            CGameEditorPluginMapMapType@ pmt = cast<CGameEditorPluginMapMapType>(editor.PluginMapType);

            // pmt.RemoveAll();

            yield();

            // pmt.PlaceMode = CGameEditorPluginMap::EPlaceMode::FreeBlock;
            // pmt.PlaceMode = CGameEditorPluginMap::EPlaceMode::Block;
            pmt.PlaceMode = CGameEditorPluginMap::EPlaceMode::GhostBlock;

            yield();

            @pmt.CursorBlockModel = blockInfo;

            yield(15);

            int nBlocks = pmt.Blocks.Length;
            log("Starting to place the block: " + blockInfo.Name, LogLevel::Info, 131, "ConvertBlockToBlock");
            print("-------------------- " + blockInfo.Name);
            while (pmt.Blocks.Length == uint(nBlocks)) {
                mouse.Click();
                yield();
            }
            editor.ButtonBlockItemCreateModeOnClick();


            yield(15);
            
            sleep(200);
            
            int2 originalPos = int2(screenWidth / 2, screenHeight / 2);
            // int2 originalPos = mouse.GetPosition();
            while (cast<CGameEditorItem>(app.Editor) is null) {
                FindBlock(@editor, blockInfo, originalPos);
                yield(5);
            }

            yield(15);

            log("Adding mesh to block.", LogLevel::Info, 153, "ConvertBlockToBlock");
            mouse.Move(button_addMesh);
            mouse.Click();
            
            yield(15);

            log("Exiting mesh modeler mode.", LogLevel::Info, 159, "ConvertBlockToBlock");
            mouse.Move(button_exitMesh);
            mouse.Click();

            yield(15);

            log("Clicking the button to set the icon.", LogLevel::Info, 165, "ConvertBlockToBlock");
            mouse.Move(button_Icon);
            mouse.Click();

            yield(15);

            log("Clicking the button to set the direction icon.", LogLevel::Info, 171, "ConvertBlockToBlock");
            mouse.Move(button_DirectionIcon);
            mouse.Click();

            // yield(15);

            log("Saving block to: " + blockSaveLocation, LogLevel::Info, 177, "ConvertBlockToBlock");
            CGameEditorItem@ editorItem = cast<CGameEditorItem>(app.Editor);
            yield(15);

            while (editorItem is null) {
                yield();
                @editorItem = cast<CGameEditorItem>(app.Editor);
            }
            
            editorItem.IdName = blockInfo.Name;

            yield(15);
            
            editorItem.FileSaveAs();

            yield(3);

            app.BasicDialogs.String = blockSaveLocation;

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

            // mouse.Move(int2(screenHeight / 2, screenWidth / 2));

            @editor = cast<CGameCtnEditorCommon@>(app.Editor);
            @pmt = editor.PluginMapType;
            pmt.Undo();

            // pmt.RemoveAll();
        }
    }

    class Utils {
        bool IsBlacklisted(const string &in blockName) {
            for (uint i = 0; i < blockToBlockBlacklist.Length; i++) {
                if (blockName.Contains(blockToBlockBlacklist[i])) {
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
    }
}