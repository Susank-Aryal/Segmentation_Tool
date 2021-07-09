classdef Crop < handle   
    properties
        image 
        path
        Imageoption
        filename
        imagePanel
        fig
    end

    methods
        function c = Crop(image,path,filename)
            c.image = image;
            c.path = path;
            c.filename = filename;
            c.Imageoption = dialog('Name', 'crop','CloseRequestFcn',@c.appclose,'Position',[500 500 290 109]);     
            uicontrol('Parent',c.Imageoption,'Style','pushbutton','String','Yes','Position',[30 27 82 25],'Fontsize',8,'Callback',@c.yesButton);
            uicontrol('Parent',c.Imageoption,'Style','pushbutton','String','No','Position',[156 27 82 25],'Fontsize',8,'Callback',@c.noButton); 
            uicontrol('Parent',c.Imageoption,'Style','text','String','Do you wish to crop the image??','Position',[25 61 270 30],'Fontsize',13,'HorizontalAlignment','left');
            c.fig = figure('NumberTitle','off', 'Name','Crop', 'CloseRequestFcn',@c.appclose, 'Resize','on');
            axes('Parent',c.fig,'Position',[0 0 1 1]);
            imshow(c.image);
            
            try
                [x, rect] = imcrop(c.image);
                c.image = imcrop(c.image,rect) ;
                ImageSegmentation(c.image,c.path,c.filename);
                delete(c.Imageoption);
                delete(c.fig)
            catch 
            end
            
        end
        
         function appclose(c,~,~)
            delete(c.Imageoption);
            delete(c.fig);
         end
        
         function yesButton(c,src,callback)
             msgbox('Make sure to double click on image after selecting area','Crop');
         end
         
         function noButton(c,src,callback)
             ImageSegmentation(c.image,c.path,c.filename);
             delete(c.Imageoption);
             delete(c.fig);
         end
    end
end
