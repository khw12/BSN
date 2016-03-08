import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class PaintingSuggestion {

	private List<String> paintings = new ArrayList<String>();
	private List<Point> points = new ArrayList<Point>();
	private List<Cluster> clusters = new ArrayList<Cluster>();
	
	private static PaintingSuggestion instance;
	
	public static PaintingSuggestion getInstance() {
		if (instance == null) {
			instance = new PaintingSuggestion();
		}
		return instance;
	}
	
	private PaintingSuggestion() {
		paintings.add("Homer");
		Point homerPoint = new Point(0, 4, "Homer");
		points.add(homerPoint);
		Cluster homerCluster = new Cluster(0);
		homerCluster.addPoint(homerPoint);
		homerCluster.setCentroid(new Point(0,4, ""));
		homerPoint.setCluster(0);
		clusters.add(homerCluster);
		paintings.add("Batman");
		Point batmanPoint = new Point(4,0, "Batman");
		points.add(batmanPoint);
		Cluster batmanCluster = new Cluster(1);
		batmanCluster.addPoint(batmanPoint);
		batmanCluster.setCentroid(new Point(4,0,""));
		batmanPoint.setCluster(1);
		clusters.add(batmanCluster);
	}
	
	public String suggest(String[] path) {
		int numHomer = 0;
		int numBatman = 0;
		for (String painting : path) {
			if (paintings.contains(painting)) {
				Point paintingPoint = findPoint(painting);
				if (paintingPoint.getCluster() == 0) {
					numHomer++;
				} else if (paintingPoint.getCluster() == 1){
					numBatman++;
				}
			}
		}
		Cluster cluster = new Cluster(5);
		if (numHomer > numBatman) {
			cluster = clusters.get(0);
		} else if (numBatman > numHomer) {
			cluster = clusters.get(1);
		} else {
			return suggestAnyPoint(path);
		}
		
		for (Point point: points) {
			List<String> paintingList = Arrays.asList(path);
			if (point.getCluster() == cluster.getId() && !paintingList.contains(point.painting)) {
				return point.painting;
			}
		}
		
		return suggestAnyPoint(path);
	}
	
	public void submit(Data path) {
		int numHomer = 0;
		int numBatman = 0;
		for (String painting : path.paintings) {
			if (paintings.contains(painting)) {
				Point paintingPoint = findPoint(painting);
				if (paintingPoint.getCluster() == 0) {
					numHomer++;
				} else if (paintingPoint.getCluster() == 1){
					numBatman++;
				}
			}
		}
		Cluster clusterToUse;
		if (numHomer > numBatman) {
			clusterToUse = clusters.get(0);
		} else if (numBatman > numHomer) {
			clusterToUse = clusters.get(1);
		} else {
			return;
		}
		
		for (String painting : path.paintings) {
			if (!painting.equals("Homer") && !painting.equals("Batman")) {
				if (paintings.contains(painting)) {
					Point paintingPoint = findPoint(painting);
					recomputeCluster(paintingPoint, path.weight, clusterToUse);
				} else {
					Point newPoint = new Point(0, 0, painting);
					paintings.add(painting);
					points.add(newPoint);
					recomputeCluster(newPoint, path.weight, clusterToUse);
				}
			}
		}
	}
	
	private String suggestAnyPoint(String[] path) {
		outer: for (Point point: points) {
			for (String paint : path) {
				if (paint.equals(point.painting)) {
					continue outer;
				}
			}
			return point.painting;
		}
		return null;
	}
	
	private Point findPoint(String painting) {
		for (Point point: points) {
			if (point.painting.equals(painting)) {
				return point;
			}
		}
		return null;
	}
	
	private void recomputeCluster(Point point, int weight, Cluster cluster) {
		double distance = Point.distance(point, cluster.getCentroid());
		double distanceToMove = (distance * weight) / 3;
		point.setX((point.getX() + cluster.getCentroid().getX() + distanceToMove) / 2);
		point.setY((point.getY() + cluster.getCentroid().getY() + distanceToMove) / 2);
		point.setCluster(cluster.id);
		cluster.addPoint(point);
		calculateCentroid(cluster);
	}
	
	private void calculateCentroid(Cluster cluster) {
		double sumX = 0;
        double sumY = 0;
        List<Point> list = cluster.getPoints();
        int n_points = list.size();

        for (Point point : list) {
            sumX += point.getX();
            sumY += point.getY();
        }

        Point centroid = cluster.getCentroid();
        if ( n_points > 0){
            double newX = sumX / n_points;
            double newY = sumY / n_points;
            centroid.setX(newX);
            centroid.setY(newY);
        }
	}
	
}
