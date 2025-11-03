function [m_adPolarAngle, m_adAzimuthalAngle, x, y, z] = phyllotaxis3D_poletopole(m_lNumberOfFrames, m_lProjectionsPerFrame, flagSelf)
% PHYLLOTAXIS3D_POLETOPOLE  Generates the pole-to-pole 3D phyllotaxis trajectory. (2024)
%
%   [m_adPolarAngle, m_adAzimuthalAngle, x, y, z] = phyllotaxis3D_poletopole(m_lNumberOfFrames, m_lProjectionsPerFrame, flagSelf)
%
%   Inputs:
%       m_lNumberOfFrames        - Number of 'interleaves' (also called 'shots')
%       m_lProjectionsPerFrame   - Number of 'segments' (also called 'spokes per interleave')
%       flagSelf                 - Logical flag if an SI spoke should be included (e.g. for self-gating)
%
%   Outputs:
%       m_adPolarAngle           - Polar angles (radians)
%       m_adAzimuthalAngle       - Azimuthal angles (radians)
%       x, y, z                  - Cartesian coordinates of the trajectory
%
%   Description:
%       Generates a 3D phyllotaxis trajectory for MRI sampling based on the
%       specified number of interleaves and segments.
%
%   Authors:
%       Davide Piccini: Original phyllotaxis implementation
%       Eva S Peper: Pole-to-pole and continuous phyllotaxis implementation (evaspeper@gmail.com)

NProj = m_lNumberOfFrames * m_lProjectionsPerFrame ; % = shots x segments
lTotalNumberOfProjections = NProj;   

m_adAzimuthalAngle=zeros(1,NProj);
m_adPolarAngle=zeros(1,NProj);

x = zeros (1, NProj);
y = zeros (1, NProj);
z = zeros (1, NProj);

if flagSelf
    N = lTotalNumberOfProjections - m_lNumberOfFrames; 
else
    N = lTotalNumberOfProjections ; 
end
kost = pi/(2*sqrt(N));

Gn = (1 + sqrt(5))/2;
Gn_ang = 2*pi - (2*pi / Gn);
count = 1;

for lk = 1:m_lProjectionsPerFrame
    for lFrame = 1:m_lNumberOfFrames	

        linter = lk + (lFrame-1) * m_lProjectionsPerFrame;

        if flagSelf && lk == 1

             m_adPolarAngle(linter) = 0;
             m_adAzimuthalAngle(linter) = 0;

        else

            % pole-to-pole phyllotaxis 
            if count<=(N/2) 
                m_adPolarAngle(linter) = kost * sqrt(2*count);
            else
                m_adPolarAngle(linter) =  pi - kost * sqrt(2*(N-count));
            end
            
            m_adAzimuthalAngle(linter) = mod ( (count)*Gn_ang, (2*pi) );
            count = count + 1;
        end

        x(linter)= sin(m_adPolarAngle(linter))*cos(m_adAzimuthalAngle(linter));
        y(linter)= sin(m_adPolarAngle(linter))*sin(m_adAzimuthalAngle(linter));
        z(linter)= cos(m_adPolarAngle(linter));

    end
end
end