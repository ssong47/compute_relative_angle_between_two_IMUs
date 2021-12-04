function yNew = apply_butterworth_filter(b,a,y)

%{
    PURPOSE: To remove noise from raw data 

    WHAT IT DOES: Applies a Butterworth filter given the filter parameters

    WRITTEN ON: 27th November 2021

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "apply_butterworth_filter.m" is placed under the University of Illinois at Urbana-Champaign license
     Copyright (c) 2021 Seung Yun Song

     Permission is hereby granted, free of charge, to any person obtaining a copyblu
     of this software and associated documentation files (the "Software"), to deal
     in the Software without restriction, including without limitation the rights
     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     copies of the Software, and to permit persons to whom the Software is
     furnished to do so, subject to the following conditions:

     The above copyright notice and this permission notice shall be included in
     all copies or substantial portions of the Software.

     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
     THE SOFTWARE.

%} 
    % Length of Data 
    yLength = length(y);
    
    % Apply filter. Use filtfilt to minimize any lag introduced by the
    % filter 
    yNew = filtfilt(b,a,[y(yLength:-1:1);y;y(yLength:-1:1)]);
    
    % Since yNew is mirrored, use half of it. 
    yNew = yNew(yLength+1:2*yLength);
end