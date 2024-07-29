classdef CM2104_Project_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure     matlab.ui.Figure
        ClearButton  matlab.ui.control.Button
        DetectConvertToPerfectShapeCheckBox  matlab.ui.control.CheckBox
        DrawButton   matlab.ui.control.Button
        LoadButton   matlab.ui.control.Button
        SaveButton   matlab.ui.control.Button
        UIAxes       matlab.ui.control.UIAxes
    end


    properties (Access = public)
        poly; % Polygon object
        coordsX; % x coordinates of the polygon
        coordsY; % y coordinates of the polygon
        checker=false; % Checker to indicate the polygon has been drawn
        midX; % Mid x point of the polygon
        midY; % Mid y point of the polygon
    end


    methods (Access = public)

        % Function that returns the coords of a perfect square if the
        % drawn/loaded polygon is close enough. Returns the drawn/loaded
        % polygon's coords if unsuccessful

        function finalCoords = detect(app)

            % Check if user has asked for the feature
            value = app.DetectConvertToPerfectShapeCheckBox.Value;
            finalCoords = app.poly.Position;
            if value

                xCoords = app.poly.Position(:, 1);

                verticeNumber = numel(xCoords);

                % Call a function based on how many points it has

                if verticeNumber == 3
                    finalCoords = convertToRightTriangle(app);

                elseif verticeNumber == 4
                    finalCoords = convertToSquare(app);

                elseif verticeNumber == 5
                    finalCoords = convertToPentagon(app);

                elseif verticeNumber == 6
                    finalCoords = convertToHexagon(app);

                end

            end
        end
        
        % Converts the polygon to an isoceles right triangle, if it is
        % close enough to it

        function finalCoords = convertToRightTriangle(app)

            % Have final coords ready in case the right triangle doesn't
            % meet the criteria

            finalCoords = app.poly.Position;

            xCoords = finalCoords(:, 1);
            yCoords = finalCoords(:, 2);
            clockwise = ispolycw(xCoords, yCoords);

            lengths=zeros(1, 3);
            angles = zeros(1, 3);

            % Store length of each side & determine which side is the
            % hypotenuse
            for i=1:numel(xCoords)
                k=i+1;

                if i==numel(xCoords)
                    k=1;

                end
                lengths(i) = norm([xCoords(k)-xCoords(i) yCoords(k)-yCoords(i)]);

                if lengths(i)==max(lengths)
                    hypP1 = i;
                    hypP2 = k;
                end

            end

            % Find the index of all the sides, to be used later

            if hypP1 == 1
                oppP1 = 2;
                adjP1 = 3;

            elseif hypP1 == 2
                oppP1 = 3;
                adjP1 = 1;

            else
                oppP1 = 1;
                adjP1 = 2;

            end
            
            % Get the lengths of all the sides

            hypLength = lengths(hypP1);
            oppLength = lengths(oppP1);
            adjLength = lengths(adjP1);


            % Calculate all the angles

            length = numel(finalCoords);


            for i=1:length/2

                if i==(length/2)
                    g = i-1;
                    f = 1;

                elseif i==1
                    g = length/2;
                    f = i+1;

                else
                    g = i-1;
                    f = i+1;

                end

                u = [finalCoords(i, 1)-finalCoords(g, 1), finalCoords(i, 2)-finalCoords(g, 2)];
                v = [finalCoords(f, 1)-finalCoords(i, 1), finalCoords(f, 2)-finalCoords(i, 2)];

                % Calculating the angles using atan2

                deter = u(1)*v(2)-v(1)*u(2);


                theta = 180+(atan2d(deter, dot(u, v)));


                if clockwise==false
                    theta = 360-theta;
                end
                angles(i) = theta;

               
            end


            % Get each angle, to be used later

            oppAngle = angles(oppP1);
            hypAngle = angles(hypP1);
            adjAngle = angles(adjP1);


            % Check if the right triangle is close enough, by checking if
            % the angles are within 10 of the desired one, and if the
            % lengths are within half the average length of the desired one

            if abs(diff([90 adjAngle])) <= 10 && abs(diff([45 hypAngle])) ...
                    <= 10 && abs(diff([45 oppAngle])) <=10

                if abs(diff([oppLength adjLength])) <= mean([oppLength adjLength])/2 ...
                        && abs(diff([mean([oppLength adjLength]) * sqrt(2)...
                        hypLength])) <= hypLength/2


                    tempxCoords = zeros(1, 3);
                    tempxCoords(1) = xCoords(1);

                    tempyCoords = zeros(1, 3);
                    tempyCoords(1) = yCoords(1);


                    for i=1:numel(xCoords)
                        j=i+1;

                        if i==numel(xCoords)
                            j=1;
                        end

                        th = 90;
                        targetLength = oppLength;

                        % If the side being made is the hypotenuse, then
                        % change the desired angle and length

                        if hypP1 == i && hypP2 == j
                            th = 45;
                            targetLength = targetLength * sqrt(2);

                        end

                        % See which direction the line segment is going
                        % and determine the correct formula for it.
                        
                        if th==45
                            if xCoords(j)-xCoords(i) < 0 && yCoords(j)-yCoords(i) < 0

                                tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));

                            elseif xCoords(j)-xCoords(i) < 0

                                tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));

                            elseif yCoords(j)-yCoords(i) < 0

                                tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));
                            else

                                tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));
                            end
                        else

                            if abs(xCoords(j)-xCoords(i)) > abs(yCoords(j)-yCoords(i))

                                if xCoords(j)-xCoords(i) < 0

                                    tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                    tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));

                                else

                                    tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                    tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));
                                end

                            elseif abs(xCoords(j)-xCoords(i)) < abs(yCoords(j)-yCoords(i))

                                if yCoords(j)-yCoords(i) < 0

                                    tempxCoords(j) = tempxCoords(i) - (targetLength*cosd(th));
                                    tempyCoords(j) = tempyCoords(i) - (targetLength*sind(th));

                                else

                                    tempxCoords(j) = tempxCoords(i) + (targetLength*cosd(th));
                                    tempyCoords(j) = tempyCoords(i) + (targetLength*sind(th));
                                end




                            end
                        end


                    end

                    % Store the final coords of the perfect square


                    finalCoords(:, 1) = tempxCoords;
                    finalCoords(:, 2) = tempyCoords;



                end



            end
        end

        % Function that returns the coordinates of a perfect square from
        % the start point of the polygon. If it doesn't meet the criteria,
        % it returns the old poylgon to be plotted again
        
        function finalCoords = convertToSquare(app)

            % Have final coords ready in case the right triangle doesn't
            % meet the criteria

            finalCoords = app.poly.Position;

            xCoords = finalCoords(:, 1);
            yCoords = finalCoords(:, 2);
            clockwise = ispolycw(xCoords, yCoords);


            lengths = zeros(1, 4);
            angles = zeros(1, 4);

            % Store length of each side
            for i=1:numel(xCoords)
                k=i+1;
                if i==numel(xCoords)
                    k=1;

                end
                lengths(i) = norm([xCoords(k)-xCoords(i) yCoords(k)-yCoords(i)]);
            end


            % Store angle of each point
            length = numel(finalCoords);


            for i=1:length/2

                if i==(length/2)
                    g = i-1;
                    f = 1;

                elseif i==1
                    g = length/2;
                    f = i+1;

                else
                    g = i-1;
                    f = i+1;

                end

                u = [finalCoords(i, 1)-finalCoords(g, 1), finalCoords(i, 2)-finalCoords(g, 2)];
                v = [finalCoords(f, 1)-finalCoords(i, 1), finalCoords(f, 2)-finalCoords(i, 2)];

                % Calculating the angles using atan2

                deter = u(1)*v(2)-v(1)*u(2);


                theta = 180+(atan2d(deter, dot(u, v)));


                if clockwise==false
                    theta = 360-theta;
                end
                angles(i) = theta;
            end


            % Set the maximum difference in length and angle that
            % is accepted

            cutOffValLength = mean(lengths)/2;
            cutOffValAngle = 10;

            lengthDiffs = [];
            angleDiffs = [];

            % Store all the differences between lengths and angles
            for i=1:numel(lengths)
                currValLength = lengths(i);



                for j=1:numel(lengths)

                    lengthDiffs(i, j) = abs(diff([currValLength lengths(j)]));
                    angleDiffs(i, j) = abs(diff([90 angles(j)]));

                end
            end




            % Check if the drawn/loaded polygon is close enough or
            % not
            if max(lengthDiffs) < cutOffValLength
                if max(angleDiffs) < cutOffValAngle

                    % Use the length of the first 2 drawn points as the
                    % target length

                    targetLength = lengths(1);

                    tempxCoords = zeros(1, 4);
                    tempxCoords(1) = xCoords(1);
    
                    tempyCoords = zeros(1, 4);
                    tempyCoords(1) = yCoords(1);

                    th = 90;


                    for i=1:numel(xCoords)
                        j=i+1;

                        if i==numel(xCoords)
                            j=1;
                        end

                        % See which direction the line segment is going
                        % and determine the correct formula for it.
                        if abs(xCoords(j)-xCoords(i)) <= abs(yCoords(j)-yCoords(i))

                            if xCoords(j)-xCoords(i) < 0 && yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*sind(th));

                            elseif xCoords(j)-xCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*sind(th));

                            elseif yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) + (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*sind(th));

                            else
                                tempxCoords(j) = tempxCoords(i) + (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*sind(th));
                            end

                        else

                            if xCoords(j)-xCoords(i) < 0 && yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));

                            elseif xCoords(j)-xCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));

                            elseif yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));

                            else
                                tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));
                            end
                        end
                    end

                    % Store the final coords of the perfect square


                    finalCoords(:, 1) = tempxCoords;
                    finalCoords(:, 2) = tempyCoords;


                end

            end

        end

        % Return the coordinates of a regular pentagon if the polygon meets
        % the criteria. Else return the old polygon's coordinates

        function finalCoords = convertToPentagon(app)

            % Have final coords ready in case the right triangle doesn't
            % meet the criteria

            finalCoords = app.poly.Position;

            xCoords = finalCoords(:, 1);
            yCoords = finalCoords(:, 2);
            clockwise = ispolycw(xCoords, yCoords);


            lengths = zeros(1, 5);
            angles = zeros(1, 5);

            % Store length of each side
            baseCheck = true;
            for i=1:numel(xCoords)
                j=i+1;
                if i==numel(xCoords)
                    j=1;

                end

                % Determine the index of the base of the pentagon by checking if there
                % is a drastic difference in the x point difference and y
                % point difference

                if abs(xCoords(j)-xCoords(i)) < abs(yCoords(j)-yCoords(i))/10 || abs(yCoords(j)-yCoords(i)) < ...
                        abs(xCoords(j)-xCoords(i))/10 && baseCheck
                    baseP1 = i;
                    baseP2 = j;
                    baseCheck=false;
                end
                lengths(i) = norm([xCoords(j)-xCoords(i) yCoords(j)-yCoords(i)]);
            end

            % Determine the index of the lines that need a different angle
            % to correctly draw the regular polygon

            if baseP2 == 3

                concernPoints(1) = 4;
                concernPoints(2) = 5;
                concernPoints(3) = 1;

            elseif baseP2 == 4

                concernPoints(1) = 5;
                concernPoints(2) = 1;
                concernPoints(3) = 2;
            elseif baseP2 == 5

                concernPoints(1) = 1;
                concernPoints(2) = 2;
                concernPoints(3) = 3;
            else
                concernPoints(1) = baseP2+1;
                concernPoints(2) = baseP2+2;
                concernPoints(3) = baseP2+3;
            end



            % Store angle of each point
            length = numel(finalCoords);


            for i=1:length/2

                if i==(length/2)
                    g = i-1;
                    f = 1;

                elseif i==1
                    g = length/2;
                    f = i+1;

                else
                    g = i-1;
                    f = i+1;

                end

                u = [finalCoords(i, 1)-finalCoords(g, 1), finalCoords(i, 2)-finalCoords(g, 2)];
                v = [finalCoords(f, 1)-finalCoords(i, 1), finalCoords(f, 2)-finalCoords(i, 2)];

                % Calculating the angles using atan2

                deter = u(1)*v(2)-v(1)*u(2);


                theta = 180+(atan2d(deter, dot(u, v)));


                if clockwise==false
                    theta = 360-theta;
                end
                angles(i) = theta;
            end


            % Set the maximum difference in length and angle that
            % is accepted

            cutOffValLength = mean(lengths)/2;
            cutOffValAngle = 40;

            lengthDiffs = [];
            angleDiffs = [];

            % Store all the differences between lengths and angles
            for i=1:numel(lengths)
                currValLength = lengths(i);



                for j=1:numel(lengths)

                    lengthDiffs(i, j) = abs(diff([currValLength lengths(j)]));
                    angleDiffs(i, j) = abs(diff([108 angles(j)]));

                end
            end



            % Check if the drawn/loaded polygon is close enough or
            % not
            if max(lengthDiffs) < cutOffValLength
                if max(angleDiffs) < cutOffValAngle


                    % Use the length of the first line drawn as the target
                    % length

                    targetLength = lengths(1);

                    tempxCoords = zeros(1, 5);
                    tempxCoords(1) = xCoords(1);

                    tempyCoords = zeros(1, 5);
                    tempyCoords(1) = yCoords(1);


                    for i=1:numel(xCoords)
                        j=i+1;

                        if i==numel(xCoords)
                            j=1;
                        end

                        th = 72;

                        % Determine if the current line being drawn is the
                        % base, and if so change the angle to 90 degrees

                        if i == baseP1 && j == baseP2 

                            th=90;

                        elseif ismember(i, concernPoints) && ismember(j, concernPoints)
                            
                            th = 54; % 108 - 54
                        end

                        % See which direction the line segment is going
                        % and determine the correct formula for it.
                        if abs(xCoords(j)-xCoords(i)) <= abs(yCoords(j)-yCoords(i))

                            if xCoords(j)-xCoords(i) < 0 && yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*sind(th));

                            elseif xCoords(j)-xCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*sind(th));

                            elseif yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) + (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*sind(th));

                            else
                                tempxCoords(j) = tempxCoords(i) + (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*sind(th));
                            end

                        else

                            if xCoords(j)-xCoords(i) < 0 && yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));

                            elseif xCoords(j)-xCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));

                            elseif yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));

                            else
                                tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));
                            end
                        end
                    end

                    % Store the final coords of the perfect square


                    finalCoords(:, 1) = tempxCoords;
                    finalCoords(:, 2) = tempyCoords;


                end

            end
        end

        % Returns the coordinates of a perfect hexagon if the polygon
        % drawn/loaded meets the criteria. Else it will return the old
        % polygon's coordinates

        function finalCoords = convertToHexagon(app)

            % Have final coords ready in case the right triangle doesn't
            % meet the criteria

            finalCoords = app.poly.Position;

            xCoords = finalCoords(:, 1);
            yCoords = finalCoords(:, 2);
            clockwise = ispolycw(xCoords, yCoords);


            lengths = zeros(1, 6);
            angles = zeros(1, 6);

            % Store length of each side
            for i=1:numel(xCoords)
                k=i+1;
                if i==numel(xCoords)
                    k=1;

                end
                lengths(i) = norm([xCoords(k)-xCoords(i) yCoords(k)-yCoords(i)]);
            end


            % Store angle of each point
            length = numel(finalCoords);


            for i=1:length/2

                if i==(length/2)
                    g = i-1;
                    f = 1;

                elseif i==1
                    g = length/2;
                    f = i+1;

                else
                    g = i-1;
                    f = i+1;

                end

                u = [finalCoords(i, 1)-finalCoords(g, 1), finalCoords(i, 2)-finalCoords(g, 2)];
                v = [finalCoords(f, 1)-finalCoords(i, 1), finalCoords(f, 2)-finalCoords(i, 2)];

                % Calculating the angles using atan2

                deter = u(1)*v(2)-v(1)*u(2);


                theta = 180+(atan2d(deter, dot(u, v)));


                if clockwise==false
                    theta = 360-theta;
                end
                angles(i) = theta;
            end


            % Set the maximum difference in length and angle that
            % is accepted

            cutOffValLength = mean(lengths)/2;
            cutOffValAngle = 40;

            lengthDiffs = [];
            angleDiffs = [];

            % Store all the differences between lengths and angles
            for i=1:numel(lengths)
                currValLength = lengths(i);


                for j=1:numel(lengths)

                    lengthDiffs(i, j) = abs(diff([currValLength lengths(j)]));
                    angleDiffs(i, j) = abs(diff([120 angles(j)]));

                end
            end


            % Check if the drawn/loaded polygon is close enough or
            % not

            if max(lengthDiffs) < cutOffValLength
                disp('hexa pass length');
                if max(angleDiffs) < cutOffValAngle
                    disp('hexa pass angle');
                    targetLength = lengths(1);

                    tempxCoords = zeros(1, 6);
                    tempxCoords(1) = xCoords(1);

                    tempyCoords = zeros(1, 6);
                    tempyCoords(1) = yCoords(1);


                    for i=1:numel(xCoords)
                        j=i+1;

                        if i==numel(xCoords)
                            j=1;
                        end

                        th=60;

                        % Determine if it's a straight line by checking if
                        % there is a drastic difference between the x
                        % difference and y difference. If so, then change
                        % the th to 90 degrees.

                        if abs(xCoords(j)-xCoords(i)) < abs(yCoords(j)-yCoords(i))/10 || abs(yCoords(j)-yCoords(i)) < ...
                                abs(xCoords(j)-xCoords(i))/10

                            th=90;
                        end



                        % See which direction the line segment is going
                        % and determine the correct formula for it.
                        if abs(xCoords(j)-xCoords(i)) < abs(yCoords(j)-yCoords(i))

                            if xCoords(j)-xCoords(i) < 0 && yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*sind(th));

                            elseif xCoords(j)-xCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*sind(th));

                            elseif yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) + (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*sind(th));

                            else
                                tempxCoords(j) = tempxCoords(i) + (targetLength*cosd(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*sind(th));
                            end

                        else

                            if xCoords(j)-xCoords(i) < 0 && yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));

                            elseif xCoords(j)-xCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) - (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));

                            elseif yCoords(j)-yCoords(i) < 0
                                tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) - (targetLength*cosd(th));

                            else
                                tempxCoords(j) = tempxCoords(i) + (targetLength*sind(th));
                                tempyCoords(j) = tempyCoords(i) + (targetLength*cosd(th));
                            end
                        end




                    end

                    % Store the final coords of the perfect square


                    finalCoords(:, 1) = tempxCoords;
                    finalCoords(:, 2) = tempyCoords;


                end

            end



        end

        % This function calculates all the angles, and plots coloured disks
        % based on it. Also doubles the marker size based on whether the
        % point is convex or concave.

        function calculateAngles(app, coords)

            % Set the colormap and colorbar limits

            c = jet(360);
            colormap(app.UIAxes, c);

            caxis(app.UIAxes, [0 360]);

            % Set x and y coords as global variables, to be used in a later
            % callback function

            app.coordsX = coords(:, 1);
            app.coordsY = coords(:, 2);

            % Determine which orientation the polygon was drawn in, as that
            % affects the angle calculation

            clockwise = ispolycw(app.coordsX, app.coordsY);

            % Calculate the angles by making vectors u and v

            length = numel(coords);


            for i=1:length/2

                % Having indexes that wrap around the array

                if i==(length/2)
                    g = i-1;
                    f = 1;

                elseif i==1
                    g = length/2;
                    f = i+1;

                else
                    g = i-1;
                    f = i+1;

                end

                u = [coords(i, 1)-coords(g, 1), coords(i, 2)-coords(g, 2)];
                v = [coords(f, 1)-coords(i, 1), coords(f, 2)-coords(i, 2)];


                % Calculating the angles using atan2 of the determinant
                % and dot product

                deter = u(1)*v(2)-v(1)*u(2);


                theta = 180+(atan2d(deter, dot(u, v)));

                if clockwise==false
                    theta = 360-theta;
                end




                % Recording the x and y coordinates

                x = coords(i);
                y = coords(i, 2);


                % Adjusting the markersize based on whether the vertice
                % is concave or convex

                if(theta>=180)
                    markerSize = 144;

                else
                    markerSize = 72;

                end

                % Plotting the colorbar and markers for each point

                scatter(app.UIAxes, x, y, markerSize, theta, 'filled');


                cb = colorbar(app.UIAxes, 'Ticks', (0:50:360), 'TickLabelInterpreter', 'tex');
                cb.TickLabels = {'\color[rgb]{1,1,1} 0', '\color[rgb]{1,1,1} 50', ...
                    '\color[rgb]{1,1,1} 100', '\color[rgb]{1,1,1} 150', '\color[rgb]{1,1,1} 200', ...
                    '\color[rgb]{1,1,1} 250', '\color[rgb]{1,1,1} 300', '\color[rgb]{1,1,1} 350'};



            end

        end

        % This function plots the MBR, and the 2 circles based on it.
        % Returns the x and y coordinates of the intersections, as well as
        % which line it happened on, to be used in the next function

        function [xi, xi2, yi, yi2, ii, ii2] = plotShapesAndIntersections(app, coords)

            % Making a polyshape object of the polygon for later use
            pgon = polyshape(coords, 'KeepCollinearPoints', true);



            % Making the MBR and plotting it and it's center using
            % midpoints

            [xBounds, yBounds] = boundingbox(pgon);
            xBounds(3) = xBounds(2);
            xBounds(4) = xBounds(2);
            xBounds(2) = xBounds(1);

            yBounds(3) = yBounds(2);
            yBounds(4) = yBounds(1);

            app.midX = ((xBounds(3)-xBounds(1))/2)+xBounds(1);
            app.midY = ((yBounds(2)-yBounds(1))/2)+yBounds(1);



            pgon1 = polyshape(xBounds, yBounds, 'KeepCollinearPoints', true);
            plot(app.UIAxes, pgon1, 'EdgeColor', 'c', 'FaceAlpha', 0);

            scatter(app.UIAxes, app.midX, app.midY, 20);


            % Plotting the 2 circles with centers at the MBR center
            % One with it's radius as the width of the MBR
            % Other one with it's radius as the length of the MBR

            r = (xBounds(3)-xBounds(1))/2;


            th = 0:pi/50:2*pi;
            xunit = r * cos(th) + app.midX;
            yunit = r * sin(th) + app.midY;

            plot(app.UIAxes, xunit, yunit, 'Color', 'green');   %Circle1

            r2 = (yBounds(2)-yBounds(1))/2;

            xunit2 = r2 * cos(th) + app.midX;
            yunit2 = r2 * sin(th) + app.midY;

            plot(app.UIAxes, xunit2, yunit2, 'Color', 'red');   %Circle2

            % Find all the points where the circles intersect with the
            % polgon. Also get the line segment on which the
            % intersection happened

            % Initialize variables needed

            xi=[];
            xi2=[];
            yi=[];
            yi2=[];
            ii=[];
            ii2=[];
            counter=1;
            counter2=1;

            for i=1:numel(app.coordsX)

                % Turn explicit line into parametric parameters
                q=i+1;
                if i==numel(app.coordsX)
                    q = 1;
                end
                p1=[app.coordsX(i); app.coordsY(i)];
                p2=[app.coordsX(q); app.coordsY(q)];

                % Get the higher and lower coordinates, to be used later

                if p2(1, 1)>p1(1,1)
                    highPointX = p2(1, 1);
                    lowPointX = p1(1,1);
                else
                    highPointX = p1(1,1);
                    lowPointX = p2(1, 1);
                end

                if p2(2, 1) > p1(2, 1)
                    highPointY = p2(2, 1);
                    lowPointY = p1(2, 1);
                else
                    highPointY = p1(2, 1);
                    lowPointY = p2(2, 1);
                end

                x0 = p1(1,1);
                y0 = p1(2,1);

                f = p2(1,1) - p1(1,1);
                g = p2(2,1) - p1(2,1);

                norm = sqrt ( f * f + g * g );


                if ( norm ~= 0.0 )
                    f = f / norm;
                    g = g / norm;
                end

                if ( f < 0.0 )
                    f = -f;
                    g = -g;
                end

                % Get the intersections between the first circle and
                % the line. Only add them into the matrix if they are
                % between the end points of the line


                root = r * r * ( f * f + g * g ) - ( f * ( app.midY - y0 ) ...
                    - g * ( app.midX - x0 ) ).^2;

                if ( root < 0.0 )
                    % Zero intersections
                    num_int = 0;

                elseif ( root == 0.0 )

                    % One intersection
                    num_int = 1;

                    t = ( f * ( app.midX - x0 ) + g * ( app.midY - y0 ) ) / ( f * f + g * g );


                    intPointX = x0+f*t;
                    intPointY = y0+g*t;

                    if intPointX<=highPointX && intPointX>=lowPointX
                        if intPointY<=highPointY && intPointY>=lowPointY
                            xi(counter,1) = intPointX;
                            yi(counter,1) = intPointY;
                            ii(counter, 1) = i;
                            counter=counter+1;
                        end
                    end

                elseif ( 0.0 < root )

                    % 2 intersections

                    num_int = 2;

                    t = ( ( f * ( app.midX - x0 ) + g * ( app.midY - y0 ) ) ...
                        - sqrt ( root ) ) / ( f * f + g * g );

                    intPointX = x0+f*t;
                    intPointY = y0+g*t;

                    if intPointX<=highPointX && intPointX>=lowPointX
                        if intPointY<=highPointY && intPointY>=lowPointY
                            xi(counter,1) = intPointX;
                            yi(counter,1) = intPointY;
                            ii(counter, 1) = i;
                            counter=counter+1;
                        end
                    end

                    t = ( ( f * ( app.midX - x0 ) + g * ( app.midY - y0 ) ) ...
                        + sqrt ( root ) ) / ( f * f + g * g );

                    intPointX = x0+f*t;
                    intPointY = y0+g*t;

                    if intPointX<=highPointX && intPointX>=lowPointX
                        if intPointY<=highPointY && intPointY>=lowPointY
                            xi(counter,1) = intPointX;
                            yi(counter,1) = intPointY;
                            ii(counter, 1) = i;
                            counter=counter+1;
                        end
                    end

                end

                % Get the intersections between the line and the second
                % circle. Only put them into the matrix if they are
                % between the endpoints

                root = r2 * r2 * ( f * f + g * g ) - ( f * ( app.midY - y0 ) ...
                    - g * ( app.midX - x0 ) ).^2;

                if ( root < 0.0 )

                    num_int = 0;

                elseif ( root == 0.0 )

                    num_int = 1;

                    t = ( f * ( app.midX - x0 ) + g * ( app.midY - y0 ) ) / ( f * f + g * g );


                    intPointX = x0+f*t;
                    intPointY = y0+g*t;

                    if intPointX<=highPointX && intPointX>=lowPointX
                        if intPointY<=highPointY && intPointY>=lowPointY
                            xi2(counter2,1) = intPointX;
                            yi2(counter2,1) = intPointY;
                            ii2(counter2, 1) = i;
                            counter2=counter2+1;
                        end
                    end

                elseif ( 0.0 < root )

                    num_int = 2;

                    t = ( ( f * ( app.midX - x0 ) + g * ( app.midY - y0 ) ) ...
                        - sqrt ( root ) ) / ( f * f + g * g );

                    intPointX = x0+f*t;
                    intPointY = y0+g*t;

                    if intPointX<=highPointX && intPointX>=lowPointX
                        if intPointY<=highPointY && intPointY>=lowPointY
                            xi2(counter2,1) = intPointX;
                            yi2(counter2,1) = intPointY;
                            ii2(counter2, 1) = i;
                            counter2=counter2+1;
                        end
                    end

                    t = ( ( f * ( app.midX - x0 ) + g * ( app.midY - y0 ) ) ...
                        + sqrt ( root ) ) / ( f * f + g * g );

                    intPointX = x0+f*t;
                    intPointY = y0+g*t;


                    if intPointX<=highPointX && intPointX>=lowPointX
                        if intPointY<=highPointY && intPointY>=lowPointY
                            xi2(counter2,1) = intPointX;
                            yi2(counter2,1) = intPointY;
                            ii2(counter2, 1) = i;
                            counter2=counter2+1;
                        end
                    end

                end


            end



            % Plot the intersections

            scatter(app.UIAxes, xi, yi, 170, 'black', 'Marker', '*');
            scatter(app.UIAxes, xi2, yi2, 170, 'black', 'Marker', '*');


        end

        % This function accepts all the intersection points and indexes of
        % line segments where it happened, and plots lines where both
        % intersections of the circles fall on the same line. Also rotates
        % and plots them for every 3 degrees till 15.

        function plotAndRotateLines(app, xi, xi2, yi, yi2, ii, ii2)

            % Loop through the number of intersections in the first circle

            j=1;
            while(j<=numel(ii))

                % Check if there is a line segment that has
                % intersections from both circles

                if ismember(ii(j), ii2)
                    k = find(ii2==ii(j));
                    search = 1;

                    % If the line segment goes through the same circle
                    % twice, then check which point is closest

                    if size(k, 1)>1
                        search = dsearchn([xi2(k(1)) yi2(k(1)); xi2(k(2)) yi2(k(2))], [xi(j) yi(j)]);

                    end

                    % Delete the index of the line segments that were
                    % found

                    ii(j) = [];
                    ii2(k(search)) = [];


                    % Save the intersection points and delete them from
                    % the matrix

                    pointX1 = xi(j);
                    pointY1 = yi(j);
                    xi(j) = [];
                    yi(j) = [];


                    pointX2 = xi2(k(search));
                    pointY2 = yi2(k(search));
                    xi2(k(search)) = [];
                    yi2(k(search)) = [];

                    j=j-1;

                    % Plot the line segment between the annular circles

                    plot(app.UIAxes, [pointX1 pointX2], [pointY1 pointY2], 'Color', 'm', 'LineWidth', 1);

                    % Rotate and plot the line segment by every 3
                    % degrees until 15 degrees

                    for i=3:3:15
                        i=i*-1;
                        tempX1 = pointX1-app.midX;
                        tempY1 = pointY1-app.midY;

                        tempX2 = pointX2-app.midX;
                        tempY2 = pointY2-app.midY;

                        % Apply rotation matrix

                        points1 = [cosd(i) -sind(i);sind(i) cosd(i)]*[tempX1;tempY1];
                        points2 = [cosd(i) -sind(i);sind(i) cosd(i)]*[tempX2;tempY2];

                        points1(1) = points1(1)+app.midX;
                        points1(2) = points1(2)+app.midY;

                        points2(1) = points2(1)+app.midX;
                        points2(2) = points2(2)+app.midY;



                        plot(app.UIAxes, [points1(1) points2(1)], [points1(2) points2(2)], 'Color', 'm', ...
                            'LineWidth', 1, 'Marker', '*', 'MarkerSize', 7);
                    end


                end
                j=j+1;
            end

        end
    end



    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: DrawButton
        function draw(app, event)

            axis(app.UIAxes, 'equal')
            % Allow user to draw polygon

            app.poly = drawpolygon(app.UIAxes);

            % Make the polygon invisible to replace with potentially new
            % polygon

            app.poly.Visible = 'off';


            hold(app.UIAxes, 'on');

            coords = detect(app);

            % Draw new polygon with new coords, that could represent
            % perfect square

            app.poly = images.roi.Polygon(app.UIAxes, 'Position', coords, 'Color', 'black',...
                'FaceAlpha', 0, 'LineWidth', 3);

            calculateAngles(app, coords);

            [xi, xi2, yi, yi2, ii, ii2] = plotShapesAndIntersections(app, coords);

            plotAndRotateLines(app, xi, xi2, yi, yi2, ii, ii2);

            % app.checker determines when the polygon has been drawn
            % completed, so that the mouseMove function can start working

            app.checker = true;




        end

        % Button pushed function: SaveButton
        function save(app, event)
            fname = input('Enter the filename: ', 's');

            while fname==""
                fname = input('Enter the filename: ', 's');
            end

            fname = strcat(fname, '.txt');
            writematrix(app.poly.Position, fname, 'Delimiter', 'space');
        end

        % Button pushed function: LoadButton
        function load(app, event)
            axis(app.UIAxes, 'equal')
            file = uigetfile({'*.csv;*.txt;*.dat'});

            % Check if the user has selected a file

            if isequal(file, 0)
                disp('Selection Cancelled');

            else

                % Reading the file

                coords = readmatrix(file);

                % Making the polygon based on the coords

                app.poly = images.roi.Polygon(app.UIAxes, 'Position', coords, 'Color', 'black',...
                    'FaceAlpha', 0, 'LineWidth', 3);

                app.poly.Visible = 'off';

                hold(app.UIAxes, 'on');

                coords = detect(app);

                app.poly = images.roi.Polygon(app.UIAxes, 'Position', coords, 'Color', 'black',...
                    'FaceAlpha', 0, 'LineWidth', 3);

                calculateAngles(app, coords);

                [xi, xi2, yi, yi2, ii, ii2] = plotShapesAndIntersections(app, coords);

                plotAndRotateLines(app, xi, xi2, yi, yi2, ii, ii2);

                app.checker = true;



            end
        end

        % Window button motion function: UIFigure
        function mouseMove(app, event)
            % Start executing the code after the polygon has been
            % drawn/loaded

            if app.checker==true

                % Check if the mouse cursor is currently in the axes

                c = app.UIFigure.CurrentPoint;
                isInAxes = c(1) >= app.UIAxes.Position(1) && ...
                    c(1) <= sum(app.UIAxes.Position([1,3])) && ...
                    c(2) >= app.UIAxes.Position(2) && ...
                    c(2) <= sum(app.UIAxes.Position([2,4]));


                if isInAxes
                    % Get the index of the endpoints that make the line
                    % segment, which is closest to the coordinates of the
                    % mouse cursor

                    minDist = 10000;
                    j=0;
                    for i=1:numel(app.coordsX)


                        CPoint = app.UIAxes.CurrentPoint(1, 1:2);


                        if i==numel(app.coordsX)
                            p1 = [app.coordsX(i) app.coordsY(i)];
                            p2 = [app.coordsX(1) app.coordsY(1)];
                        else
                            p1 = [app.coordsX(i) app.coordsY(i)];
                            p2 = [app.coordsX(i+1) app.coordsY(i+1)];
                        end





                        check = dot((p2-p1), (CPoint-p1));
                        check = (check)/((norm(p2-p1))^2);

                        if check>1
                            dist = norm(CPoint-p2);
                        elseif check<0
                            dist = norm(CPoint-p1);
                        else
                            dist = sqrt((norm(CPoint-p1))^2 - (check * (norm(p2-p1)))^2);
                        end

                        minDist = min(dist, minDist);
                        if minDist == dist
                            j=i;
                        end
                    end


                    if j==numel(app.coordsX)

                        Xs = [app.coordsX(j) app.coordsX(1)];
                        Ys = [app.coordsY(j) app.coordsY(1)];
                    else
                        Xs = [app.coordsX(j) app.coordsX(j+1)];
                        Ys = [app.coordsY(j) app.coordsY(j+1)];
                    end

                    % Delete the previous line highlighted if there is
                    % one
                    delete(findobj(app.UIFigure, 'Color', 'r', 'Tag', 'Removable'));

                    % Plot the red line on the line that the mouse is
                    % closest to

                    plot(app.UIAxes, Xs, Ys, 'Color', 'r', 'LineWidth', 2, 'Tag', 'Removable');



                else
                    % Delete the red line if the user moves the cursor
                    % outside the axes

                    delete(findobj(app.UIFigure, 'Color', 'r', 'Tag', 'Removable'));

                end
            end
        end

        % Button pushed function: ClearButton
        function clear(app, event)
            cla(app.UIAxes);
            app.checker=false;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.149 0.149 0.149];
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.WindowButtonMotionFcn = createCallbackFcn(app, @mouseMove, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, {''; ''; ''})
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XColor = [0.8 0.8 0.8];
            app.UIAxes.YColor = [0.8 0.8 0.8];
            app.UIAxes.Position = [9 83 621 398];

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @save, true);
            app.SaveButton.BackgroundColor = [0.0745 0.6235 1];
            app.SaveButton.Position = [46 43 100 22];
            app.SaveButton.Text = {'Save'; ''};

            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @load, true);
            app.LoadButton.BackgroundColor = [0 1 0];
            app.LoadButton.Position = [198 43 100 22];
            app.LoadButton.Text = 'Load';

            % Create DrawButton
            app.DrawButton = uibutton(app.UIFigure, 'push');
            app.DrawButton.ButtonPushedFcn = createCallbackFcn(app, @draw, true);
            app.DrawButton.BackgroundColor = [1 1 0];
            app.DrawButton.Position = [362 43 100 22];
            app.DrawButton.Text = 'Draw';

            % Create DetectConvertToPerfectShapeCheckBox
            app.DetectConvertToPerfectShapeCheckBox = uicheckbox(app.UIFigure);
            app.DetectConvertToPerfectShapeCheckBox.Text = {'Detect & Convert to Perfect Shape'; ''};
            app.DetectConvertToPerfectShapeCheckBox.FontColor = [1 1 1];
            app.DetectConvertToPerfectShapeCheckBox.Position = [235 9 207 22];

            % Create ClearButton
            app.ClearButton = uibutton(app.UIFigure, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @clear, true);
            app.ClearButton.BackgroundColor = [0.7176 0.2745 1];
            app.ClearButton.Position = [510 43 100 22];
            app.ClearButton.Text = 'Clear';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CM2104_Project_exported

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