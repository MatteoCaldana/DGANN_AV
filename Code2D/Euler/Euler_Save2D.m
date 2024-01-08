function [] = Euler_Save2D(Mesh, Save_times,Q_save,ind_save,visc_save,ptc_hist,pnc_hist,maxvisc_hist,t_hist,sim_time,gas_gamma,gas_const, data_fname)
% Saving data to files

    
    % Make solution dirctories if not existing
    mkdir('OUTPUT')
    
    fname = sprintf('OUTPUT/%s_DATA.mat',data_fname);
    x = Mesh.x;
    y = Mesh.y;
    invV = Mesh.invV;
    J = Mesh.J;
    Mass = Mesh.MassMatrix;
    
    
    save(fname,'x','y','invV','J','Save_times','Q_save','ind_save','visc_save','ptc_hist','pnc_hist','maxvisc_hist','t_hist','sim_time','gas_gamma','gas_const')
    
    
end