%Basic code reference
% https://www.mathworks.com/matlabcentral/fileexchange/64725-thresholdsegmentationbot 
classdef ImageSegmentation < handle    
    properties     
        threshold_low,
        threshold_upper
        Img
        ImageSettingControl
        img_axis
        watershed_segmentation_img
        imageshandler
        first_slider
        second_slider
        overlapCheckbox
        imagePanel
        thresholdValue
        b_image
        thresholdSegmentation_img
        thresholdMinValue
        text1
        text2
        sigmaValue
        originalImage
        segmented_overlaper
        segment_fig
        thresholdSegmentation
        segment_overlap_handler
        save_image_file
        filter_fil
        filtered_image
        h
        filterVal
        im
        std
        ran
        com
    end
    
    methods  
        
        function segment_app = ImageSegmentation(image,path,filename)
            %building of main application gui
            segment_app.originalImage = image;
            segment_app.thresholdValue = 0.5;
            segment_app.sigmaValue = 1;
            segment_app.thresholdMinValue = 0.1;
            segment_app.Img = image; 
            segment_app.thresholdSegmentation.thresholdValue = segment_app.thresholdValue;
            segment_app.thresholdSegmentation.sigmaValue = segment_app.sigmaValue;
            segment_app.thresholdSegmentation.thresholdMinValue = segment_app.thresholdMinValue;

            segment_app.ImageSettingControl = dialog('Name', 'Image Segmentation App','CloseRequestFcn',@segment_app.SegmentationClose,'Position',[100 100 525 500]);
            
            uipanel('Parent',segment_app.ImageSettingControl,'FontSize',9,'Position',[.034 .82 .95 .16]);
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','text','String','Image','Position',[30 455 45 22],'Fontsize',10);
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','text','String',path,'Position',[105 459 300 18],'Fontsize',9,'BackgroundColor',[1,1,1],'HorizontalAlignment','left');
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','pushbutton','String','Change Image','Position',[415 458 82 25],'Fontsize',8,'Callback',@segment_app.imageChange,'Tag','ImageChanging')
            
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','pushbutton','String','Help','Position',[415 423 75 22],'Fontsize',9,'Callback',@segment_app.helpButton)
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','text','String','Filename','Position',[30 423 65 22],'Fontsize',10);
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','text','String',filename,'Position',[105 427 150 18],'Fontsize',9,'BackgroundColor',[1,1,1],'HorizontalAlignment','left');
            uipanel('Parent',segment_app.ImageSettingControl,'Title','Brightness & Contrast','FontSize',9,'Position',[.034 .64 .45 .17]);
            
            segment_app.imagePanel = uipanel('Parent',segment_app.ImageSettingControl,'Title','Image','FontSize',9,'Position',[.53 .16 .45 .65]);  
            
            uipanel('Parent',segment_app.ImageSettingControl,'Title','Segment','FontSize',9,'Position',[.034 .24 .45 .39]);
            
            axes('Parent',segment_app.imagePanel,'Position',[.05 .06 .9 .9]);
            segment_app.imageshandler = imshow(segment_app.Img);
            hold on
            
            segment_app.segmented_overlaper = zeros(size(segment_app.Img,1),size(segment_app.Img,2),3);segment_app.segmented_overlaper(:,:,3) = 1;
            segment_app.segment_overlap_handler = imshow(segment_app.segmented_overlaper);
            segment_app.segment_overlap_handler.AlphaData = zeros(size(segment_app.Img));
            hold off
                            
            first_slider = uicontrol('Parent',segment_app.ImageSettingControl,'Style','slider','Min',0,'Max',1,'Value',0,'Position',[35 370 200 15],'Tag','firstSlider');
            addlistener(first_slider,'Value','PostSet',@segment_app.control_Slider_Settings);
            
            second_slider = uicontrol('Parent',segment_app.ImageSettingControl,'Style','slider','Min',0,'Max',1,'Value',1,'Position',[35 340 200 15],'Tag','secondSlider');
            addlistener(second_slider,'Value','PostSet', @segment_app.control_Slider_Settings);
            
            segment_app.text1 = uicontrol('Parent',segment_app.ImageSettingControl,'Style','text','Fontsize',8,'Position',[35 280 80 15],'String',sprintf('Threshold: %.02f',segment_app.thresholdValue));
            threshold_slider = uicontrol('Parent',segment_app.ImageSettingControl,'Style','slider','Value',segment_app.thresholdValue,'Position',[35 260 200 15],'Tag','thresholdSlider','Max',0.99,'Min',0.01);
            addlistener(threshold_slider,'Value','PostSet',@segment_app.control_Slider_Settings);
            
            segment_app.text2 = uicontrol('Parent',segment_app.ImageSettingControl,'Style','text','Fontsize',8,'Position',[35 230 100 15],'String',sprintf('Fragmentation: %.02f',1-segment_app.thresholdMinValue));
            fragmentation_slider = uicontrol('Parent',segment_app.ImageSettingControl,'Style','slider','Value',1-segment_app.thresholdMinValue,'Position',[35 210 200 15],'Tag','fragmentationSlider','Max',0.99,'Min',0.01);
            addlistener(fragmentation_slider,'Value','PostSet',@segment_app.control_Slider_Settings);
            
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','text','Fontsize',8,'Position',[25 170 80 15],'String','Smoothing : ');
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','popupmenu','Position',[100 175 100 15],'String',{'Sigma 1','Sigma 2','Sigma 3','Sigma 4','Sigma 5'},'Callback',@segment_app.SmoothingManager); 
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','pushbutton','Fontsize',9,'Position',[150 130 80 25],'Callback',@segment_app.segmentationButton,'String','Segment');
            segment_app.overlapCheckbox = uicontrol('Parent',segment_app.ImageSettingControl,'Style','checkbox','String','Overlap On Image','Position',[30 135 110 20],'Callback',@segment_app.overlapCheckboxCallback);
            
            uipanel('Parent',segment_app.ImageSettingControl,'Title','Filter','FontSize',9,'Position',[.034 .035 .45 .2]);
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','pushbutton','Fontsize',9,'Position',[305,40,79,22],'String','Close','Callback',@segment_app.SegmentationClose);
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','pushbutton','Fontsize',9,'Position',[414,40,79,22],'String','Save','Callback',@segment_app.saveButton);

            uicontrol('Parent',segment_app.ImageSettingControl,'Style','text','Fontsize',8,'Position',[25 70 80 15],'String','Smoothing : ');
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','popupmenu','Position',[100 75 100 15],'String',{'Not Selected','Complement','Standard-deviation','Range'},'Callback',@segment_app.filterValue); 
            uicontrol('Parent',segment_app.ImageSettingControl,'Style','pushbutton','Fontsize',9,'Position',[150 30 80 25],'Callback',@segment_app.applyfilter,'String','Apply');
        end        
        
        %Cicconet. M (2017) ThresholdSegmentationBot. Mathworks [Online]. Available from: https://www.mathworks.com/matlabcentral/fileexchange/64725-thresholdsegmentationbot [Accessed 17 April 2021].
        function segmentationButton(segment_app,src,callbackdata)
            %Appliying watershard segmentation when the segment button is
            %pressed with the selected values
            segment_app.b_image = filterGauss2D(segment_app.Img,segment_app.sigmaValue);
            segment_app.thresholdSegmentation_img = segment_app.b_image > segment_app.thresholdValue;
            if max(segment_app.thresholdSegmentation_img(:)) == 0
                segment_app.watershed_segmentation_img = segment_app.thresholdSegmentation_img;
            else
                segment_app.watershed_segmentation_img = bwWatershed(segment_app.thresholdSegmentation_img, segment_app.thresholdMinValue);
            end        
            segment_app.overlapCheckbox.Value = 0;
        
            segment_app.segment_fig = figure('NumberTitle','off', 'Name','Segmentation');
            smoothing_img = subplot(1,3,1);
            imshow(segment_app.b_image)
            smoothing_img.Title.String = sprintf('Sigma: %d', segment_app.sigmaValue);
            
            threshold_img = subplot(1,3,2);
            imshow(segment_app.thresholdSegmentation_img)
            threshold_img.Title.String = sprintf('Threshold: %.02f', segment_app.thresholdValue);
            
            fragmantation_img= subplot(1,3,3);
            imshow(segment_app.watershed_segmentation_img)
            fragmantation_img.Title.String = sprintf('Fragmentation: %.02f', 1-segment_app.thresholdMinValue);
            linkaxes([smoothing_img, threshold_img, fragmantation_img],'xy')
        end
        
        %opening of notpad displaying the help options
        function helpButton(segment_app,~,~)
            !notepad help.txt
        end
        
        %Making use of matlab inbuilt filters
        function applyfilter(segment_app,src,callbackdata)
            segment_app.filter_fil = figure('NumberTitle','off', 'Name','Filter');
            if segment_app.filterVal == 4
                segment_app.std = stdfilt(segment_app.originalImage);
                imshow(segment_app.std);
            elseif segment_app.filterVal == 3
                segment_app.ran = rangefilt(segment_app.originalImage);
                imshow(segment_app.ran);
            elseif segment_app.filterVal == 2
                segment_app.com= imcomplement(segment_app.originalImage);
                imshow(segment_app.com);
            else
                delete(segment_app.filter_fil);
            end
        end
        
        
        %WHen saved button is pressed saving all the images used by the
        %user
        function saveButton(segment_app,src,callbackdata)
            try
            [write_path,write_filename] = uiputfile({'*.jpg;*.png','Images (.jpg, .png)'});
            imwrite(segment_app.save_image_file,[strcat(write_filename,'brightness_contrast_'),write_path]);
            B = labeloverlay(segment_app.save_image_file,imbinarize(segment_app.save_image_file,graythresh(segment_app.save_image_file)));
            imwrite(B,[strcat(write_filename,'brightness_overlayed_'),write_path]);
            imwrite(segment_app.b_image,[strcat(write_filename,['sigma_' num2str(segment_app.sigmaValue) '_']),write_path]);
            imwrite(segment_app.thresholdSegmentation_img,[strcat(write_filename,['Threshold_' num2str(segment_app.thresholdValue) '_']),write_path]);
            imwrite(segment_app.watershed_segmentation_img,[strcat(write_filename,['Fragmentation_' num2str(segment_app.thresholdMinValue) '_']),write_path]);
            imwrite(segment_app.std,[strcat(write_filename,'standered_deviation_filter_'),write_path]);
            imwrite(segment_app.ran,[strcat(write_filename,'range_filter_'),write_path]);
            imwrite(segment_app.com,[strcat(write_filename,'complement_filter_'),write_path]);
            catch
            end
        end
        
        %The oberlapping option after threshold segmentation
        function overlapCheckboxCallback(segment_app,src,~)
            if ~isempty(segment_app.watershed_segmentation_img)
                if src.Value == 1
                    segment_app.segment_overlap_handler.AlphaData = 0.5 * segment_app.watershed_segmentation_img;
                elseif src.Value == 0
                	segment_app.segment_overlap_handler.AlphaData = zeros(size(segment_app.watershed_segmentation_img));
                end
            end
        end
        
        function SmoothingManager(segment_app,src,~)
            segment_app.sigmaValue = src.Value;
        end
        
        function filterValue(segment_app,src,~)
            segment_app.filterVal = src.Value;
        end
        
        %deleting of overall application window when close btn is pressed
        function SegmentationClose(segment_app,~,~)
            delete(segment_app.ImageSettingControl);
            delete(segment_app.segment_fig);
            delete(segment_app.filter_fil);
        end
        
        %Getting and implementing the value of sliders into the image in
        %real time
        function control_Slider_Settings(segment_app,~,cd)
         try
            object_tag = cd.AffectedObject.Tag;                                                                                   
            object_value = cd.AffectedObject.Value;
            
            if strcmp(object_tag,'fragmentationSlider')
                segment_app.thresholdMinValue = 1-object_value;
                segment_app.text2.String = sprintf('Fragmentation: %.02f',1-segment_app.thresholdMinValue);  
                
            elseif strcmp(object_tag,'thresholdSlider')
                segment_app.thresholdValue = object_value;
                segment_app.text1.String = sprintf('Threshold: %.02f',segment_app.thresholdValue);
            else
                if strcmp(object_tag,'firstSlider')
                    segment_app.threshold_low = object_value;
                elseif strcmp(object_tag,'secondSlider')
                    segment_app.threshold_upper = object_value;
                end
                image_file = segment_app.Img;
                image_file(image_file < segment_app.threshold_low) = segment_app.threshold_low;
                image_file(image_file > segment_app.threshold_upper) = segment_app.threshold_upper;
                image_file = image_file-min(image_file(:));
                image_file = image_file/max(image_file(:));
                segment_app.imageshandler.CData = image_file;
                segment_app.save_image_file = image_file;
            end
         catch
         end
        end
        
        %changing the image into gray scale
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
        
        %change image feature 
        function imageChange(segment_app,src,~)
            [filename, pathname] = uigetfile({'*.tif;*.jpg;*.png','Images (.tif, .jpg, .png)'});
            if filename ~= 0
                path = strcat(pathname,filename);
                img = imgintoGray(segment_app,path);
                if strcmp(src.Tag,'ImageChanging')
                    segment_app.Img = img;
                    segment_app.imageshandler.CData = img;
                end
            end
            segment_app.first_slider.Value = 0; segment_app.second_slider.Value = 1;
            segment_app.overlapCheckbox.Value = 0; segment_app.threshold_low = 0; 
            segment_app.threshold_upper = 1;    segment_app.watershed_segmentation_img = [];
        end
        
    end
end
