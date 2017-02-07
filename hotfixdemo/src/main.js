//include('JPDemoController.js');
defineClass('ViewController', {
    showController: function() {
        var ctrl = JPDemoController.alloc().init();
        self.navigationController().pushViewController_animated(ctrl, NO);
    }
});

require('UILabel, UIColor, UIFont, UIScreen, UIImageView, UIImage')

var screenWidth = UIScreen.mainScreen().bounds().width;
var screenHeight = UIScreen.mainScreen().bounds().height;

defineClass('JPDemoController: UIViewController', {
            viewDidLoad: function() {
            self.super().viewDidLoad();
            self.view().setBackgroundColor(UIColor.whiteColor());
            var bgColor = UIColor.colorWithRed_green_blue_alpha(1, 1, .3, 1);
            self.view().setBackgroundColor(bgColor);
            
            var size = 100;
            var imgView = UIImageView.alloc().initWithFrame({x: (screenWidth - size)/2, y: 150, width: size, height: size});
            imgView.setImage(UIImage.imageWithContentsOfFile(resourcePath('apple.png')));
            self.view().addSubview(imgView);
            
            var label = UILabel.alloc().initWithFrame({x: 0, y: 310, width: screenWidth, height: 30});
            label.setText("JSPatch");
            label.setTextAlignment(1);
            label.setFont(UIFont.systemFontOfSize(25));
            self.view().addSubview(label);
            }, 
            })
