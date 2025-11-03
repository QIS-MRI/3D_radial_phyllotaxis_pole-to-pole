function [m_adPolarAngle_out, m_adAzimuthalAngle_out, x, y, z] = phyllotaxis3D_angleUpdate_original (m_lNumberOfFrames, m_lProjectionsPerFrame, flagSelf, nPC)
% PHYLLOTAXIS3D_ANGLEUPDATE_ORIGINAL  Generates the original 3D phyllotaxis trajectory with different spokes per phase cycle (nPC). (2024)
%
%   [m_adPolarAngle_out, m_adAzimuthalAngle_out, x, y, z] = phyllotaxis3D_angleUpdate_original(m_lNumberOfFrames, m_lProjectionsPerFrame, flagSelf, nPC)
%
%   Inputs:
%       m_lNumberOfFrames        - Number of 'interleaves' (also called 'shots')
%       m_lProjectionsPerFrame   - Number of 'segments' (also called 'spokes per interleave')
%       flagSelf                 - Logical flag if an SI spoke should be included (e.g. for self-gating)
%       nPC                      - Number of phase cycles (this dimension can also be use for other consecutive sampling, e.g. time points)
%
%   Outputs:
%       m_adPolarAngle_out       - Polar angles (radians)
%       m_adAzimuthalAngle_out   - Azimuthal angles (radians)
%       x, y, z                  - Cartesian coordinates of the trajectory
%
%   Description:
%       Generates a 3D phyllotaxis trajectory for MRI sampling based on the
%       specified number of interleaves, segments and phase cycles. The
%       angle update function updates the polar angle between phase
%       cycles so that no spokes are repeated.
%
%   Authors:
%       Davide Piccini: Original phyllotaxis implementation
%       Eva S Peper: Pole-to-pole and continuous phyllotaxis implementation (evaspeper@gmail.com)
%       Eva S Peper: Angle update implementation for phase cycles (evaspeper@gmail.com)

NProj = m_lNumberOfFrames * m_lProjectionsPerFrame; % = shots x segments
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

for lpc = 1:nPC % number of phase cycles nPC

    count = 1 + N * (lpc-1); % includes nPC counter

    for lk = 1:m_lProjectionsPerFrame % segments
        for lFrame = 1:m_lNumberOfFrames % shots

            linter = lk + (lFrame-1) * m_lProjectionsPerFrame;

            if flagSelf && lk == 1

                m_adPolarAngle(linter) = 0;
                m_adAzimuthalAngle(linter) = 0;

            else

                % original phyllotaxis updating the polar angle between phase cycles (nPC)
                m_adPolarAngle(linter) = kost * sqrt(count - (N * (lpc-1)) );
                m_adAzimuthalAngle(linter) = mod ( (count)*Gn_ang, (2*pi) );
                count = count + 1;

            end

            xtmp(linter)= sin(m_adPolarAngle(linter))*cos(m_adAzimuthalAngle(linter));
            ytmp(linter)= sin(m_adPolarAngle(linter))*sin(m_adAzimuthalAngle(linter));
            ztmp(linter)= cos(m_adPolarAngle(linter));

        end
    end

    % store for all nPCs
    x(:,:,lpc) = xtmp;
    y(:,:,lpc) = ytmp;
    z(:,:,lpc) = ztmp;
    m_adPolarAngle_out(:,:,lpc) = m_adPolarAngle;
    m_adAzimuthalAngle_out(:,:,lpc) = m_adAzimuthalAngle;

end
end