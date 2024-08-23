function [m_adPolarAngle m_adAzimuthalAngle x y z] = phyllotaxis3D_original(m_lNumberOfFrames, m_lProjectionsPerFrame, flagSelf)
% original phyllotaxis 

NProj = m_lNumberOfFrames * m_lProjectionsPerFrame; % = shot x segments
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

            % original phyllotaxis 
            m_adPolarAngle(linter) = kost * sqrt(count);
            m_adAzimuthalAngle(linter) = mod ( (count)*Gn_ang, (2*pi) );
            count = count + 1;

        end

        x(linter)= sin(m_adPolarAngle(linter))*cos(m_adAzimuthalAngle(linter));
        y(linter)= sin(m_adPolarAngle(linter))*sin(m_adAzimuthalAngle(linter));
        z(linter)= cos(m_adPolarAngle(linter));

    end
end

end