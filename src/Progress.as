[Setting name="Progress"]
bool isProgressOpen = true;

void RenderInterface() {


    if (UI::Begin("Progress", isProgressOpen, UI::WindowFlags::NoCollapse)) {
        UI::Text("Progress:");

        float progress = 0.0f;

        if (currentConversion == Conversion::blockToBlock) {
            int x = BlockToBlock::totalBlocks - BlockToBlock::totalBlocksConverted;
            if (BlockToBlock::totalBlocks == 0) { progress = 1.0f; }
            else { progress = 1.0f - (float(x) / float(BlockToBlock::totalBlocks)); }
        } else if (currentConversion == Conversion::blockToItem) {
            int x = BlockToItem::totalBlocks - BlockToItem::totalBlocksConverted;
            if (BlockToItem::totalBlocks == 0) { progress = 1.0f; }
            else { progress = 1.0f - (float(x) / float(BlockToItem::totalBlocks)); }
        } else if (currentConversion == Conversion::itemToItem) {
            int x = ItemToItem::totalItems - ItemToItem::totalItemsConverted;
            if (ItemToItem::totalItems == 0) { progress = 1.0f; }
            else { progress = 1.0f - (float(x) / float(ItemToItem::totalItems)); }
        }


        UI::ProgressBar(progress);
    }
    UI::End();
}