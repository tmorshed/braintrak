function timecourse(f,nocolor,smoothed)
	if nargin < 3 || isempty(smoothed)
		smoothed = false;
	end

	if nargin < 2 || isempty(nocolor)
		nocolor = false;
	end

	figure
	
	m = f.model;
	if isempty(m.param_symbols)
		disp('Retrieving model parameter symbols and units using new instance of the class')
		m = feval(class(m));
	end

	param_names = m.param_names;
	xyz_req = ~m.xyz_present();
	xyz_names = {'X','Y','Z'};
	xyz_symbols = {'X','Y','Z'};
	xyz_units = {'','',''};
	xyz = f.xyz;
	
	if smoothed
		yv = f.fitted_params;
		for j = 1:size(yv,2)
			yv(:,j) = smooth(yv(:,j),60);
		end
		xyz = xyz(:,xyz_req);
		for j = 1:size(xyz,2)
			xyz(:,j) = smooth(xyz(:,j),60);
		end
		yv = [yv, xyz];
	else
		yv = f.fitted_params;
		yv = [yv, xyz(:,xyz_req)];
	end

	param_names = [param_names,xyz_names(xyz_req)];
	param_symbols = [m.param_symbols,xyz_symbols(xyz_req)];
	param_units = [m.param_units,xyz_units(xyz_req)];

	n_rows = ceil(length(param_names)/2);
	n_cols = 2;
	a_idx = @(a,b) n_cols*(a-1) + b;
	ax = [];

	xv = 1:f.latest;
	
	
	for j = 1:length(param_names)
		ax(end+1) = subplot(n_rows,n_cols,1+a_idx(ceil(j/2),mod(j-1,2)));
		box(ax(j),'on');

		if nocolor
			plot(xv/3600,yv(:,j))
			hold on
		else
			f.plot_statecolored(xv/3600,yv(:,j));
		end

		xlabel('Time (h)','FontSize',10)
		if isempty(param_units{j})
			ylabel(ax(j),param_symbols{j})
		else
			ylabel(ax(j),sprintf('%s (%s)',param_symbols{j},param_units{j}),'FontSize',10)
		end

		%ylabel(ax(j),m.param_names{j})
		drawnow
	end



