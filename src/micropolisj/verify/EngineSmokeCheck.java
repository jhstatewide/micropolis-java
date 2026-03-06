package micropolisj.verify;

import micropolisj.engine.Micropolis;
import micropolisj.engine.Speed;

public class EngineSmokeCheck
{
	public static void main(String[] args)
	{
		try {
			Micropolis city = new Micropolis();
			city.setSpeed(Speed.FAST);

			int startCycle = city.getAnimationCycle();

			for (int i = 0; i < 50; i++) {
				city.animate();
			}

			int endCycle = city.getAnimationCycle();
			if (startCycle == endCycle) {
				System.err.println("Smoke check failed: animation cycle did not advance.");
				System.exit(1);
			}

			System.out.println("Engine smoke check passed.");
		}
		catch (Throwable t) {
			System.err.println("Smoke check failed with exception: " + t);
			t.printStackTrace(System.err);
			System.exit(1);
		}
	}
}
