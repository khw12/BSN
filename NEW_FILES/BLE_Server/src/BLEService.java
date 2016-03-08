import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/bleservice")
public class BLEService {
	
	private PaintingSuggestion suggestion = PaintingSuggestion.getInstance();
	
	@GET
	@Path("{current}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getSuggestion(@PathParam("current") String paths) {
		String[] path = paths.split(",");
		return Response.status(200).entity(suggestion.suggest(path)).build();
	}
	
	@POST
	@Path("{weight}/{path}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public Response submitData(@PathParam("weight") int weight,  @PathParam("path") String paths) {
		Data path = new Data();
		path.weight = weight;
		path.paintings = paths.split(",");
		suggestion.submit(path);
		return Response.status(200).build();
	}

}
