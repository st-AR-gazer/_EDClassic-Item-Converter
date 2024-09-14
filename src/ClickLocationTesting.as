void Render() {
    return;

    RenderDots();

    if (UI::Begin("Click Location Testing", isProgressOpen, UI::WindowFlags::NoCollapse)) {
        UI::Text("Click Location Testing:");

        renderdotlocationX = UI::InputFloat("Click Location X: " + renderdotlocationX, renderdotlocationX, 10);
        renderdotlocationY = UI::InputFloat("Click Location Y: " + renderdotlocationY, renderdotlocationY, 10);

    }
    UI::End();
}

auto renderdotlocationX = 100.0f;
auto renderdotlocationY = 100.0f;

void RenderDots() {
    nvg::BeginPath();
    // Set the color for the circles
    nvg::FillColor(vec4(1.0f, 0.0f, 0.0f, 1.0f));

    vec2 center(renderdotlocationX, renderdotlocationY);
    float radius = 5.0f;
    nvg::Circle(center, radius);
    nvg::Fill();


    // End the path (optional for circles)
    nvg::ClosePath();
}


/* x/y
 * Icon button item block to item: 445.000, 417.000
 * 
 * 
 * Add mesh button block to block: 440.000, 420.000
 * (then exit mesh modler if possible programatically without having to click the buttons yayy)
 * 
 * Icon button block to block: 445.000, 255.000
 * 
 * 
 * 
 * 
 * Icon button: 985.000, 550.000 (South East)
 * 
 * 
 * 
 */