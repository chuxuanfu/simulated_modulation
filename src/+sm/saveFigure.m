function saveFigure(fig,name)
p=fullfile(sm.root(),'reports','figures'); if ~isfolder(p), mkdir(p); end
exportgraphics(fig,fullfile(p,[name '.png']),'Resolution',150); close(fig);
end
