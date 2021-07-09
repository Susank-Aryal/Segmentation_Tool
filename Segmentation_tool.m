%A basic gui that user sees at a very first look into the application
classdef Segmentation_tool < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure      matlab.ui.Figure
        SelectImageForSegmentationLabel  matlab.ui.control.Label
        BrowseButton  matlab.ui.control.Button
        ExitButton    matlab.ui.control.Button
    end

 %Converts the image into gray scale image   
    methods (Access = public)
        function img = imgintoGray(~,path)
            img = imread(path);
                if size(img,3) == 2 || size(img,3) > 3
                    img = img(:,:,1);
                elseif size(img,3) == 3
                    img = rgb2gray(img);
                end
                if isa(img,'uint8')
                    img = double(img)/255;
                elseif isa(img,'uint16')
                    img = double(img)/65535;     
                end
        end
    end
    

    methods (Access = private)

        function ExitButtonPushed(app, event)
            delete(app.UIFigure);
        end
% When the button is pressed the gui askes user to select image in those
% formats which is automatically changed to gray scale
        function BrowseButtonPushed(app, event)
            [filename, pathname] = uigetfile({'*.tif;*.jpg;*.png','Images (.tif, .jpg, .png)'});
            if filename ~= 0
                path = strcat(pathname,filename);
                img = imgintoGray(app,path);
                Crop(img,path,filename);
                delete(app.UIFigure);
            end           
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [500 500 290 109];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';
 
            app.SelectImageForSegmentationLabel = uilabel(app.UIFigure);
            app.SelectImageForSegmentationLabel.FontSize = 16;
            app.SelectImageForSegmentationLabel.Position = [33 61 232 30];
            app.SelectImageForSegmentationLabel.Text = 'Select Image For Segmentation';

            % Create BrowseButton
            app.BrowseButton = uibutton(app.UIFigure, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [162 26 91 22];
            app.BrowseButton.Text = 'Browse';

            % Create ExitButton
            app.ExitButton = uibutton(app.UIFigure, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.Position = [41 26 91 22];
            app.ExitButton.Text = 'Exit';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Segmentation_tool

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end